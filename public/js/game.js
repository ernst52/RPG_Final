let currentCharacter = null;
let allEquipment = [];
let currentFilter = 'all';

// ==========================================
// INITIALIZATION
// ==========================================

document.addEventListener('DOMContentLoaded', () => {
    initializeGame();
    setupEventListeners();
});

async function initializeGame() {
    try {
        await loadCharacters();
    } catch (error) {
        console.error('Failed to initialize game:', error);
        showNotification('Failed to load game data!', 'error');
    }
}

// ==========================================
// EVENT LISTENERS
// ==========================================

function setupEventListeners() {
    // Logout button
    document.getElementById('logoutBtn')?.addEventListener('click', handleLogout);
    
    // Back button
    document.getElementById('backBtn')?.addEventListener('click', backToCharacterSelection);
    
    // Add XP button
    document.getElementById('addXPBtn')?.addEventListener('click', handleAddXP);

    // 👇 NEW Reduce XP button
    document.getElementById('reduceXPBtn')?.addEventListener('click', handleReduceXP);
    
    // Modal close buttons
    document.querySelectorAll('.modal-close').forEach(btn => {
        btn.addEventListener('click', closeModals);
    });
    
    // Filter tabs
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.addEventListener('click', (e) => {
            const filter = e.target.dataset.filter;
            setFilter(filter);
        });
    });
    
    // Click outside modal to close
    document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModals();
            }
        });
    });
}

// ==========================================
// CHARACTER LOADING
// ==========================================

async function loadCharacters() {
    try {
        const response = await fetch('/api/characters');
        const data = await response.json();
        
        if (data.success) {
            displayCharacters(data.characters);
        } else {
            throw new Error(data.error || 'Failed to load characters');
        }
    } catch (error) {
        console.error('Error loading characters:', error);
        showNotification('Failed to load characters!', 'error');
    }
}

function displayCharacters(characters) {
    const container = document.getElementById('characterList');
    container.innerHTML = '';
    
    if (characters.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: var(--text-dim); font-size: 1.5rem;">No characters available!</p>';
        return;
    }
    
    characters.forEach(char => {
        const card = createCharacterCard(char);
        container.appendChild(card);
    });
}

function createCharacterCard(char) {
    const card = document.createElement('div');
    card.className = 'character-card';
    
    // If player owns this character, show their progress
    // If not, show it's available to select
    const isOwned = char.is_owned === 1;
    
    // Main card click behavior (selects/creates the character)
    card.onclick = () => {
        if (isOwned) {
            selectCharacter(char.char_id);
        } else {
            selectNewCharacter(char.template_id);
        }
    };
    
    const initial = char.name.charAt(0).toUpperCase();
    
    let levelInfo;
    if (isOwned) {
        levelInfo = `
            <div class="character-card-level-row">
                <div class="character-card-level">
                    <span class="level-badge">LEVEL ${char.level_num}</span>
                    <span class="xp-badge">${char.xp} XP</span>
                </div>
                <button class="reset-char-btn" onclick="event.stopPropagation(); handleDeleteCharacter(${char.char_id}, '${char.name}')">
                    RESET
                </button>
            </div>
            
        `;
    } else {
        levelInfo = `
            <div class="character-card-level">
                <span class="level-badge" style="background: var(--primary-blue);">AVAILABLE</span>
            </div>
        `;
    }
    
    card.innerHTML = `
        <div class="character-card-portrait" data-initial="${initial}"></div>
        <div class="character-card-name">${char.name}</div>
        <div class="character-card-class">${char.class_name}</div>
        ${levelInfo}
    `;
    
    return card;
}



// ==========================================
// CHARACTER SELECTION
// ==========================================

async function selectCharacter(charId) {
    try {
        const response = await fetch(`/api/character/${charId}`);
        const data = await response.json();
        
        if (data.success) {
            currentCharacter = data.character;
            await loadAllEquipment();
            showGameScreen();
            displayCharacterDetails();
            displayEquippedItems();
            displayAvailableEquipment();
        } else {
            throw new Error(data.error || 'Failed to load character');
        }
    } catch (error) {
        console.error('Error selecting character:', error);
        showNotification('Failed to load character!', 'error');
    }
}

async function selectNewCharacter(templateId) {
    try {
        const response = await fetch('/api/character/select', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ templateId })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Character created!', 'success');
            // Now select the newly created character
            await selectCharacter(data.charId);
        } else {
            showNotification(data.error || 'Failed to create character!', 'error');
        }
    } catch (error) {
        console.error('Error selecting character:', error);
        showNotification('Connection error!', 'error');
    }
}

function showGameScreen() {
    document.getElementById('characterSelection').classList.remove('active');
    document.getElementById('gameScreen').classList.add('active');
}

function backToCharacterSelection() {
    document.getElementById('gameScreen').classList.remove('active');
    document.getElementById('characterSelection').classList.add('active');
    currentCharacter = null;
}

// ==========================================
// CHARACTER DISPLAY
// ==========================================

function displayCharacterDetails() {
    if (!currentCharacter) return;
    
    // Update character info
    document.getElementById('charName').textContent = currentCharacter.name;
    document.getElementById('charClass').textContent = currentCharacter.class_name;
    document.getElementById('charDescription').textContent = currentCharacter.class_description || 'A mysterious warrior';
    document.getElementById('charLevel').textContent = currentCharacter.level_num;
    
    // Update portrait with initial
    const portrait = document.getElementById('charPortrait');
    const initial = currentCharacter.name.charAt(0).toUpperCase();
    portrait.style.display = 'flex';
    portrait.style.alignItems = 'center';
    portrait.style.justifyContent = 'center';
    portrait.style.fontSize = '5rem';
    portrait.style.fontFamily = 'Press Start 2P, monospace';
    portrait.style.color = 'var(--bg-darker)';
    portrait.textContent = initial;
    
    // Update XP bar
    const currentXP = currentCharacter.xp;
    const nextLevelXP = currentCharacter.xp_for_next_level || 9999;
    const xpPercentage = (currentXP / nextLevelXP) * 100;
    
    document.getElementById('currentXP').textContent = currentXP;
    document.getElementById('nextLevelXP').textContent = nextLevelXP;
    document.getElementById('xpProgress').style.width = `${Math.min(xpPercentage, 100)}%`;
    
    // Display stats
    displayStats();
}

function calculateTotalStats() {
    const baseStats = { ...currentCharacter.stats };
    (currentCharacter.equipment || []).forEach(item => {
        if (!item.stat_bonus) return;
        try {
            const bonuses = JSON.parse(item.stat_bonus);
            for (const [stat, value] of Object.entries(bonuses)) {
                baseStats[stat] = (baseStats[stat] || 0) + value;
            }
        } catch {}
    });
    return baseStats;
}

function displayStats() {
    const statsContainer = document.getElementById('statsContainer');
    statsContainer.innerHTML = '';

    const stats = calculateTotalStats();

    for (const [statName, value] of Object.entries(stats)) {
        const statItem = document.createElement('div');
        statItem.className = 'stat-item';
        statItem.innerHTML = `
            <span class="stat-name">${statName}</span>
            <span class="stat-value">${value}</span>
        `;
        statsContainer.appendChild(statItem);
    }
}


// ==========================================
// EQUIPMENT LOADING
// ==========================================

async function loadAllEquipment() {
    try {
        const response = await fetch('/api/equipment');
        const data = await response.json();
        
        if (data.success) {
            allEquipment = data.equipment;
        } else {
            throw new Error(data.error || 'Failed to load equipment');
        }
    } catch (error) {
        console.error('Error loading equipment:', error);
        showNotification('Failed to load equipment!', 'error');
    }
}

// ==========================================
// EQUIPPED ITEMS DISPLAY
// ==========================================

function displayEquippedItems() {
    // Clear all slots first
    for (let i = 1; i <= 5; i++) {
        const slotContent = document.getElementById(`slot-${i}`);
        slotContent.innerHTML = '<div class="empty-slot">EMPTY</div>';
    }
    
    // Fill equipped slots
    if (currentCharacter.equipment && currentCharacter.equipment.length > 0) {
        currentCharacter.equipment.forEach(item => {
            const slotContent = document.getElementById(`slot-${item.slot_type_id}`);
            slotContent.innerHTML = `
                <div class="equipped-item">
                    <div class="equipped-item-name">${item.name}</div>
                    <div class="equipped-item-level">LV ${item.level_requirement}</div>
                    <button class="unequip-btn" onclick="unequipItem(${item.slot_type_id})">
                        UNEQUIP
                    </button>
                </div>
            `;
        });
    }
}

// ==========================================
// AVAILABLE EQUIPMENT DISPLAY
// ==========================================

function displayAvailableEquipment() {
    const container = document.getElementById('equipmentInventory');
    container.innerHTML = '';
    
    const filteredEquipment = currentFilter === 'all' 
        ? allEquipment 
        : allEquipment.filter(item => item.slot_type_id == currentFilter);
    
    if (filteredEquipment.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: var(--text-dim); margin-top: 2rem;">No items in this category</p>';
        return;
    }
    
    filteredEquipment.forEach(item => {
        const itemCard = createEquipmentCard(item);
        container.appendChild(itemCard);
    });
}

function createEquipmentCard(item) {
    const card = document.createElement('div');
    const isLocked = currentCharacter.level_num < item.level_requirement;
    
    card.className = 'equipment-item' + (isLocked ? ' level-locked' : '');
    card.onclick = () => {
        if (!isLocked) {
            showEquipmentModal(item);
        } else {
            showNotification(`Level ${item.level_requirement} required!`, 'error');
        }
    };
    
    // Parse stat bonuses
    let bonusesHTML = '';
    if (item.stat_bonus) {
        try {
            const bonuses = JSON.parse(item.stat_bonus);
            bonusesHTML = Object.entries(bonuses)
                .map(([stat, value]) => `<span class="bonus-badge">+${value} ${stat}</span>`)
                .join('');
        } catch (e) {
            console.error('Error parsing stat bonus:', e);
        }
    }
    
    card.innerHTML = `
        <div class="item-header">
            <div class="item-name">${item.name}</div>
            <div class="item-slot-badge">${item.slot_name}</div>
        </div>
        <div class="item-info">
            <div>LV: ${item.level_requirement}</div>
            <div>DUR: ${item.durability}/${item.max_durability}</div>
        </div>
        ${bonusesHTML ? `<div class="item-bonuses">${bonusesHTML}</div>` : ''}
    `;
    
    return card;
}

// ==========================================
// FILTER SYSTEM
// ==========================================

function setFilter(filter) {
    currentFilter = filter;
    
    // Update active tab
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.classList.remove('active');
        if (tab.dataset.filter === filter) {
            tab.classList.add('active');
        }
    });
    
    displayAvailableEquipment();
}

// ==========================================
// EQUIPMENT MODAL
// ==========================================

function showEquipmentModal(item) {
    const modal = document.getElementById('equipmentModal');
    
    // Set item details
    document.getElementById('modalItemName').textContent = item.name;
    document.getElementById('modalItemSlot').textContent = item.slot_name;
    document.getElementById('modalItemLevel').textContent = item.level_requirement;
    document.getElementById('modalItemDurability').textContent = `${item.durability}/${item.max_durability}`;
    
    // Set item icon (using slot emoji)
    const iconMap = {
        'Head': '🪖',
        'Chest': '🦺',
        'Legs': '👖',
        'Weapon': '🔫',
        'Shield': '🛡️'
    };
    const modalIcon = document.getElementById('modalItemIcon');
    modalIcon.textContent = iconMap[item.slot_name] || '📦';
    modalIcon.style.fontSize = '4rem';
    modalIcon.style.textAlign = 'center';
    modalIcon.style.padding = '2rem';
    
    // Display bonuses
    const bonusesContainer = document.getElementById('modalItemBonuses');
    bonusesContainer.innerHTML = '<h4 style="margin-top: 1rem; color: var(--primary-green);">BONUSES</h4>';
    
    if (item.stat_bonus) {
        try {
            const bonuses = JSON.parse(item.stat_bonus);
            for (const [stat, value] of Object.entries(bonuses)) {
                bonusesContainer.innerHTML += `
                    <div class="item-property">
                        <span class="property-label">${stat}:</span>
                        <span style="color: var(--primary-green);">+${value}</span>
                    </div>
                `;
            }
        } catch (e) {
            bonusesContainer.innerHTML += '<p style="color: var(--text-dim);">No bonuses</p>';
        }
    } else {
        bonusesContainer.innerHTML += '<p style="color: var(--text-dim);">No bonuses</p>';
    }
    
    // Set up equip button
    const equipBtn = document.getElementById('modalEquipBtn');
    equipBtn.onclick = () => equipItem(item.item_id);
    
    modal.classList.add('active');
}

// ==========================================
// EQUIP/UNEQUIP ACTIONS
// ==========================================

async function equipItem(itemId) {
    try {
        const response = await fetch('/api/equip', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                charId: currentCharacter.char_id,
                itemId: itemId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Item equipped successfully!', 'success');
            closeModals();
            await refreshCharacter();
        } else {
            showNotification(data.error || 'Failed to equip item!', 'error');
        }
    } catch (error) {
        console.error('Error equipping item:', error);
        showNotification('Connection error!', 'error');
    }
}

async function unequipItem(slotTypeId) {
    try {
        const response = await fetch('/api/unequip', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                charId: currentCharacter.char_id,
                slotTypeId: slotTypeId
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('Item unequipped!', 'success');
            await refreshCharacter();
        } else {
            showNotification(data.error || 'Failed to unequip item!', 'error');
        }
    } catch (error) {
        console.error('Error unequipping item:', error);
        showNotification('Connection error!', 'error');
    }
}

// ==========================================
// XP SYSTEM
// ==========================================

async function handleAddXP() {
    const btn = document.getElementById('addXPBtn');
    btn.disabled = true;
    btn.style.opacity = '0.5';
    
    try {
        const response = await fetch('/api/addxp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                charId: currentCharacter.char_id,
                amount: 50
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('+50 XP gained!', 'success');
            
            if (data.leveledUp) {
                showLevelUpModal(data.newLevel);
            }
            
            await refreshCharacter();
        } else {
            showNotification(data.error || 'Failed to add XP!', 'error');
        }
    } catch (error) {
        console.error('Error adding XP:', error);
        showNotification('Connection error!', 'error');
    } finally {
        setTimeout(() => {
            btn.disabled = false;
            btn.style.opacity = '1';
        }, 1000);
    }
}

async function handleReduceXP() {
    const btn = document.getElementById('reduceXPBtn');
    btn.disabled = true;
    btn.style.opacity = '0.5';

    try {
        const response = await fetch('/api/reducexp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                charId: currentCharacter.char_id,
                amount: 50
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('-50 XP lost!', 'error');
            await refreshCharacter();
        } else {
            showNotification(data.error || 'Failed to reduce XP!', 'error');
        }
    } catch (error) {
        console.error('Error reducing XP:', error);
        showNotification('Connection error!', 'error');
    } finally {
        setTimeout(() => {
            btn.disabled = false;
            btn.style.opacity = '1';
        }, 1000);
    }
}

function showLevelUpModal(newLevel) {
    const modal = document.getElementById('levelUpModal');
    document.getElementById('newLevelNum').textContent = newLevel;
    modal.classList.add('active');
    
    // Play celebration animation
    setTimeout(() => {
        closeModals();
    }, 3000);
}

// ==========================================
// UTILITY FUNCTIONS
// ==========================================

async function refreshCharacter() {
    if (!currentCharacter) return;

    try {
        const response = await fetch(`/api/character/${currentCharacter.char_id}`);
        const data = await response.json();

        if (data.success) {
            currentCharacter = data.character;
            updateCharacterUI(); // <- use the new function here
        }
    } catch (error) {
        console.error('Error refreshing character:', error);
    }
}


function closeModals() {
    document.querySelectorAll('.modal').forEach(modal => {
        modal.classList.remove('active');
    });
}

function showNotification(message, type = 'success') {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = 'notification show ' + type;
    
    setTimeout(() => {
        notification.classList.remove('show');
    }, 3000);
}

async function handleLogout() {
    try {
        await fetch('/api/logout', { method: 'POST' });
        window.location.href = '/';
    } catch (error) {
        console.error('Logout error:', error);
        window.location.href = '/';
    }
}

async function updateCharacterUI() {
    if (!currentCharacter) return;

    // Update core info
    displayCharacterDetails();

    // Update equipped items
    displayEquippedItems();

    // Update available equipment (locks/unlocks, bonuses)
    displayAvailableEquipment();
}

// ==========================================
// CHARACTER DELETION
// ==========================================

async function handleDeleteCharacter(charId, charName) {
    if (!confirm(`Are you sure you want to permanently reset the character "${charName}"? This cannot be undone.`)) {
        return;
    }
    
    try {
        const response = await fetch(`/api/character/${charId}`, {
            method: 'DELETE'
        });

        const data = await response.json();
        
        if (data.success) {
            showNotification(`Character ${charName} reset successfully!`, 'success');
            // Refresh the character selection screen
            await loadCharacters(); 
        } else {
            showNotification(data.error || 'Failed to reset character!', 'error');
        }
    } catch (error) {
        console.error('Error deleting character:', error);
        showNotification('Connection error during character reset!', 'error');
    }
}


// ==========================================
// KEYBOARD SHORTCUTS
// =========================================a=

document.addEventListener('keydown', (e) => {
    // ESC to close modals
    if (e.key === 'Escape') {
        closeModals();
    }
    
    // X to add XP (debug)
    if (e.key === 'x' && currentCharacter) {
        handleAddXP();
    }
});