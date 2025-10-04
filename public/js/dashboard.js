let currentTable = 'player';

document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    loadTableData('player');
});

function setupEventListeners() {
    document.getElementById('logoutBtn')?.addEventListener('click', handleLogout);
    document.getElementById('backToGameBtn')?.addEventListener('click', () => {
        window.location.href = '/game';
    });

    document.getElementById('refreshDataBtn')?.addEventListener('click', () => {
        loadTableData(currentTable); // Calls the function to reload data for the current table
        showNotification(`${formatTableName(currentTable)} refreshed!`, 'success');
    });

    document.querySelectorAll('.table-menu-item').forEach(item => {
        item.addEventListener('click', (e) => {
            const tableName = e.target.dataset.table;
            selectTable(tableName);
        });
    });
}

function selectTable(tableName) {
    currentTable = tableName;
    
    // Update active state
    document.querySelectorAll('.table-menu-item').forEach(item => {
        item.classList.remove('active');
        if (item.dataset.table === tableName) {
            item.classList.add('active');
        }
    });
    
    // Update title
    document.getElementById('tableTitle').textContent = formatTableName(tableName);
    
    // Load data
    loadTableData(tableName);
}

async function loadTableData(tableName) {
    try {
        const response = await fetch(`/api/dashboard/${tableName}`);
        const data = await response.json();
        
        if (data.success) {
            displayTableData(data.rows);
        } else {
            showNotification(data.error || 'Failed to load table data', 'error');
        }
    } catch (error) {
        console.error('Error loading table data:', error);
        showNotification('Connection error!', 'error');
    }
}

function displayTableData(rows) {
    const container = document.getElementById('tableData');
    
    if (!rows || rows.length === 0) {
        container.innerHTML = '<p style="color: var(--text-dim);">No data in this table.</p>';
        return;
    }
    
    const columns = Object.keys(rows[0]);
    
    let html = '<table class="data-table"><thead><tr>';
    columns.forEach(col => {
        html += `<th>${col}</th>`;
    });
    html += '</tr></thead><tbody>';
    
    rows.forEach(row => {
        html += '<tr>';
        columns.forEach(col => {
            let value = row[col];
            if (value === null) value = '<i style="color: var(--text-dim);">NULL</i>';
            html += `<td>${value}</td>`;
        });
        html += '</tr>';
    });
    
    html += '</tbody></table>';
    container.innerHTML = html;
}

function formatTableName(name) {
    return name.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
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

// ==========================================
// SQL QUERY TERMINAL
// ==========================================

let terminalPolling = null;

function toggleSQLTerminal() {
    const terminal = document.getElementById('sqlTerminal');
    const wasMinimized = terminal.classList.contains('minimized');
    terminal.classList.toggle('minimized');
    
    if (wasMinimized) {
        startSQLPolling();
    } else {
        stopSQLPolling();
    }
}

function startSQLPolling() {
    if (terminalPolling) return;
    fetchSQLLog();
    terminalPolling = setInterval(fetchSQLLog, 2000);
}

function stopSQLPolling() {
    if (terminalPolling) {
        clearInterval(terminalPolling);
        terminalPolling = null;
    }
}

async function fetchSQLLog() {
    try {
        const response = await fetch('/api/sql-log');
        const data = await response.json();
        
        if (data.success && data.queries) {
            displaySQLQueries(data.queries);
        }
    } catch (error) {
        console.error('Error fetching SQL log:', error);
    }
}

function displaySQLQueries(queries) {
    const terminalBody = document.getElementById('sqlTerminalBody');
    const countElement = document.getElementById('sqlQueryCount');
    
    if (queries.length === 0) {
        terminalBody.innerHTML = '<div style="color: var(--text-dim); padding: 1rem;">No queries yet...</div>';
        countElement.textContent = '0 queries';
        return;
    }
    
    // Group queries by API endpoint
    const grouped = {};
    queries.forEach(entry => {
        const api = entry.api || 'Unknown API';
        if (!grouped[api]) {
            grouped[api] = [];
        }
        grouped[api].push(entry);
    });
    
    terminalBody.innerHTML = '';
    
    Object.entries(grouped).forEach(([api, apiQueries]) => {
        const group = document.createElement('div');
        group.className = 'sql-api-group';
        
        const header = document.createElement('div');
        header.className = 'sql-api-header';
        header.onclick = () => group.classList.toggle('collapsed');
        header.innerHTML = `
            <span class="sql-api-name">${escapeHtml(api)}</span>
            <div style="display: flex; gap: 1rem; align-items: center;">
                <span class="sql-api-count">${apiQueries.length} ${apiQueries.length === 1 ? 'query' : 'queries'}</span>
                <span class="sql-api-toggle">▼</span>
            </div>
        `;
        
        const queriesContainer = document.createElement('div');
        queriesContainer.className = 'sql-api-queries';
        
        apiQueries.forEach(entry => {
            const timestamp = new Date(entry.timestamp).toLocaleTimeString();
            const div = document.createElement('div');
            div.className = 'sql-query-entry';
            
            let paramStr = '';
            if (entry.params && entry.params.length > 0) {
                const params = entry.params.map(p => {
                    if (typeof p === 'string') return `"${p}"`;
                    if (p === null) return 'NULL';
                    return String(p);
                });
                paramStr = `<div class="sql-query-params">PARAMS: [${params.join(', ')}]</div>`;
            }
            
            div.innerHTML = `
                <div class="sql-query-timestamp">[${timestamp}]</div>
                <div class="sql-query-text">${escapeHtml(entry.query)}</div>
                ${paramStr}
            `;
            
            queriesContainer.appendChild(div);
        });
        
        group.appendChild(header);
        group.appendChild(queriesContainer);
        terminalBody.appendChild(group);
    });
    
    countElement.textContent = `${queries.length} ${queries.length === 1 ? 'query' : 'queries'}`;
}

async function clearSQLLog() {
    try {
        const response = await fetch('/api/sql-log/clear', {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showNotification('SQL log cleared!', 'success');
            fetchSQLLog(); // Refresh display
        }
    } catch (error) {
        console.error('Error clearing SQL log:', error);
        showNotification('Failed to clear log!', 'error');
    }
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

document.addEventListener('DOMContentLoaded', () => {
    const terminal = document.getElementById('sqlTerminal');
    if (terminal && !terminal.classList.contains('minimized')) {
        startSQLPolling();
    }
});

window.addEventListener('beforeunload', () => {
    stopSQLPolling();
});