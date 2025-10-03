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

function toggleSQLTerminal() {
    const terminal = document.getElementById('sqlTerminal');
    terminal.classList.toggle('minimized');
}

function logSQLQuery(query) {
    const terminalBody = document.getElementById('sqlTerminalBody');
    const timestamp = new Date().toLocaleTimeString();
    
    const entry = document.createElement('div');
    entry.className = 'sql-query-entry';
    entry.innerHTML = `
        <div class="sql-query-timestamp">[${timestamp}]</div>
        <div class="sql-query-text">${escapeHtml(query)}</div>
    `;
    
    terminalBody.insertBefore(entry, terminalBody.firstChild);
    
    // Keep only last 50 queries
    while (terminalBody.children.length > 50) {
        terminalBody.removeChild(terminalBody.lastChild);
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
    return text.replace(/[&<>"']/g, m => map[m]);
}

// Intercept fetch calls to log SQL queries
const originalFetch = window.fetch;
window.fetch = function(...args) {
    const url = args[0];
    if (typeof url === 'string' && url.startsWith('/api/')) {
        logSQLQuery(`REQUEST: ${args[1]?.method || 'GET'} ${url}`);
    }
    return originalFetch.apply(this, args);
};