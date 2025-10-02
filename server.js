require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const session = require('express-session');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
}).promise();

// Test database connection
pool.query('SELECT 1')
    .then(() => console.log('✅ Database connected successfully'))
    .catch(err => console.error('❌ Database connection failed:', err));

// Middleware
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false } // Set to true if using HTTPS
}));

// Serve HTML pages
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'login.html'));
});

app.get('/game', (req, res) => {
    if (!req.session.playerId) {
        return res.redirect('/');
    }
    res.sendFile(path.join(__dirname, 'views', 'game.html'));
});

// API: Login/Register
app.post('/api/login', async (req, res) => {
    const { username, email } = req.body;
    
    console.log(`🔐 LOGIN ATTEMPT: ${username} (${email})`);
    
    try {
        // Check if player exists
        const [players] = await pool.query(
            'SELECT * FROM player WHERE username = ? OR email = ?',
            [username, email]
        );
        
        let player;
        
        if (players.length > 0) {
            player = players[0];
            console.log(`✅ EXISTING PLAYER FOUND: ID ${player.player_id}`);
        } else {
            // Create new player
            const [result] = await pool.query(
                'INSERT INTO player (username, email) VALUES (?, ?)',
                [username, email]
            );
            player = { player_id: result.insertId, username, email };
            console.log(`✨ NEW PLAYER CREATED: ID ${player.player_id}`);
        }
        
        req.session.playerId = player.player_id;
        req.session.username = player.username;
        
        res.json({ success: true, player });
    } catch (error) {
        console.error('❌ LOGIN ERROR:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Get player's characters
app.get('/api/characters', async (req, res) => {
    if (!req.session.playerId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    
    console.log(`📋 FETCHING CHARACTERS FOR PLAYER ${req.session.playerId}`);
    
    try {
        const [characters] = await pool.query(`
            SELECT 
                c.*,
                cl.class_name,
                l.level_num,
                l.xp_required as xp_for_next_level
            FROM charactertable c
            JOIN classtable cl ON c.class_id = cl.class_id
            JOIN leveltable l ON c.level_id = l.level_id
            WHERE c.player_id = ? AND c.is_active = 1
            ORDER BY c.char_id
        `, [req.session.playerId]);
        
        console.log(`✅ FOUND ${characters.length} CHARACTERS`);
        res.json({ success: true, characters });
    } catch (error) {
        console.error('❌ ERROR FETCHING CHARACTERS:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Get character details
app.get('/api/character/:id', async (req, res) => {
    const charId = req.params.id;
    
    console.log(`🎯 FETCHING DETAILS FOR CHARACTER ${charId}`);
    
    try {
        // Get character info
        const [characters] = await pool.query(`
            SELECT 
                c.*,
                cl.class_name,
                cl.description as class_description,
                l.level_num,
                l.xp_required as xp_for_next_level
            FROM charactertable c
            JOIN classtable cl ON c.class_id = cl.class_id
            JOIN leveltable l ON c.level_id = l.level_id
            WHERE c.char_id = ? AND c.player_id = ?
        `, [charId, req.session.playerId]);
        
        if (characters.length === 0) {
            return res.status(404).json({ error: 'Character not found' });
        }
        
        const character = characters[0];
        
        // Get character stats
        const [stats] = await pool.query(`
            SELECT s.stat_name, cs.value
            FROM characterstats cs
            JOIN stat s ON cs.stat_id = s.stat_id
            WHERE cs.char_id = ?
        `, [charId]);
        
        character.stats = stats.reduce((acc, stat) => {
            acc[stat.stat_name] = stat.value;
            return acc;
        }, {});
        
        // Get equipped items
        const [equipment] = await pool.query(`
            SELECT 
                e.*,
                st.slot_name,
                ce.slot_type_id
            FROM characterequipment ce
            JOIN equipment e ON ce.item_id = e.item_id
            JOIN slottype st ON ce.slot_type_id = st.slot_type_id
            WHERE ce.char_id = ?
        `, [charId]);
        
        character.equipment = equipment;
        
        console.log(`✅ CHARACTER LOADED: ${character.name} (Level ${character.level_num})`);
        res.json({ success: true, character });
    } catch (error) {
        console.error('❌ ERROR FETCHING CHARACTER:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Get all available equipment
app.get('/api/equipment', async (req, res) => {
    console.log(`🛡️ FETCHING ALL EQUIPMENT`);
    
    try {
        const [equipment] = await pool.query(`
            SELECT 
                e.*,
                st.slot_name
            FROM equipment e
            JOIN slottype st ON e.slot_type_id = st.slot_type_id
            ORDER BY e.slot_type_id, e.level_requirement, e.name
        `);
        
        console.log(`✅ FOUND ${equipment.length} EQUIPMENT ITEMS`);
        res.json({ success: true, equipment });
    } catch (error) {
        console.error('❌ ERROR FETCHING EQUIPMENT:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Equip item
app.post('/api/equip', async (req, res) => {
    const { charId, itemId } = req.body;
    
    console.log(`⚔️ EQUIPPING ITEM ${itemId} TO CHARACTER ${charId}`);
    
    try {
        // Get slot type for the item
        const [items] = await pool.query(
            'SELECT slot_type_id FROM equipment WHERE item_id = ?',
            [itemId]
        );
        
        if (items.length === 0) {
            return res.status(404).json({ success: false, error: 'Item not found' });
        }
        
        const slotTypeId = items[0].slot_type_id;
        
        // Try to equip (triggers will validate)
        await pool.query(`
            INSERT INTO characterequipment (char_id, item_id, slot_type_id)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE item_id = ?
        `, [charId, itemId, slotTypeId, itemId]);
        
        console.log(`✅ ITEM ${itemId} EQUIPPED SUCCESSFULLY`);
        res.json({ success: true, message: 'Item equipped successfully' });
    } catch (error) {
        console.error('❌ EQUIP ERROR:', error);
        
        // Parse MySQL error messages for user-friendly response
        let errorMessage = error.message;
        if (error.message.includes('too low to equip')) {
            errorMessage = 'Your level is too low to equip this item!';
        } else if (error.message.includes('0 durability')) {
            errorMessage = 'This item is broken and cannot be equipped!';
        }
        
        res.status(400).json({ success: false, error: errorMessage });
    }
});

// API: Unequip item
app.post('/api/unequip', async (req, res) => {
    const { charId, slotTypeId } = req.body;
    
    console.log(`🗑️ UNEQUIPPING SLOT ${slotTypeId} FROM CHARACTER ${charId}`);
    
    try {
        await pool.query(
            'DELETE FROM characterequipment WHERE char_id = ? AND slot_type_id = ?',
            [charId, slotTypeId]
        );
        
        console.log(`✅ SLOT UNEQUIPPED SUCCESSFULLY`);
        res.json({ success: true, message: 'Item unequipped successfully' });
    } catch (error) {
        console.error('❌ UNEQUIP ERROR:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Add XP to character
app.post('/api/addxp', async (req, res) => {
    const { charId, amount } = req.body;
    
    console.log(`⭐ ADDING ${amount} XP TO CHARACTER ${charId}`);
    
    try {
        // Get current character data
        const [characters] = await pool.query(
            'SELECT xp, level_id FROM charactertable WHERE char_id = ?',
            [charId]
        );
        
        if (characters.length === 0) {
            return res.status(404).json({ success: false, error: 'Character not found' });
        }
        
        const currentXp = characters[0].xp;
        const currentLevelId = characters[0].level_id;
        const newXp = currentXp + amount;
        
        // Check if level up is possible
        const [nextLevel] = await pool.query(
            'SELECT level_id, level_num, xp_required FROM leveltable WHERE level_id > ? ORDER BY level_id LIMIT 1',
            [currentLevelId]
        );
        
        let newLevelId = currentLevelId;
        let leveledUp = false;
        
        if (nextLevel.length > 0 && newXp >= nextLevel[0].xp_required) {
            newLevelId = nextLevel[0].level_id;
            leveledUp = true;
            console.log(`🎉 LEVEL UP! Character reached level ${nextLevel[0].level_num}`);
        }
        
        // Update character
        await pool.query(
            'UPDATE charactertable SET xp = ?, level_id = ? WHERE char_id = ?',
            [newXp, newLevelId, charId]
        );
        
        console.log(`✅ XP UPDATED: ${currentXp} -> ${newXp}`);
        res.json({ 
            success: true, 
            newXp, 
            leveledUp,
            newLevel: leveledUp ? nextLevel[0].level_num : null
        });
    } catch (error) {
        console.error('❌ ADD XP ERROR:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// API: Logout
app.post('/api/logout', (req, res) => {
    console.log(`👋 PLAYER ${req.session.playerId} LOGGING OUT`);
    req.session.destroy();
    res.json({ success: true });
});

// Start server
app.listen(PORT, () => {
    console.log(`
╔═══════════════════════════════════════╗
║   🎮 SOYJAK PARTY GAME SERVER 🎮     ║
║   Server running on port ${PORT}        ║
║   http://localhost:${PORT}              ║
╚═══════════════════════════════════════╝
    `);
});