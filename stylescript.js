function renderSessionInfo() {

    let container = document.getElementById("sessionContainer");

    // array objects 
    let sessionArray = [
        { label: "Username", value: sessionData.username },
        { label: "Role", value: sessionData.role },
        { label: "Current Login", value: sessionData.currentLogin },
        { label: "Last Login", value: sessionData.lastLogin },
        { label: "Visits", value: sessionData.visits },
        { label: "Session ID", value: sessionData.sessionId },
        { label: "User ID", value: sessionData.userId }
    ];

    container.innerHTML = "";

    sessionArray.forEach(item => {
        container.innerHTML += `
            <div class="session-item">
                <strong>${item.label}</strong><br>
                <span>${item.value}</span>
            </div>
        `;
    });
}
function toggleSidebar() {
    let sidebar = document.getElementById("sidebar");

    if (sidebar.style.left === "0px") {
        sidebar.style.left = "-300px";
    } else {
        sidebar.style.left = "0px";
        renderSessionInfo();
    }
}
function sortInternships(sortBy) {
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    
    if(sortBy === 'latest') document.getElementById('sortLatest').classList.add('active');
    else if(sortBy === 'oldest') document.getElementById('sortOldest').classList.add('active');
    else if(sortBy === 'az') document.getElementById('sortAZ').classList.add('active');
    else if(sortBy === 'za') document.getElementById('sortZA').classList.add('active');
    
    const sortLabels = {
        'latest': 'Latest',
        'oldest': 'Oldest',
        'az': 'A-Z',
        'za': 'Z-A'
    };
    const sortStatus = document.getElementById('sortStatus');
    if(sortStatus) {
        sortStatus.textContent = `Sorted by ${sortLabels[sortBy] || 'Latest'}`;
    }
    
    // Show loading
    const grid = document.getElementById('internshipsGrid');
    const originalContent = grid.innerHTML;
    grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; padding: 60px;"><i class="fas fa-spinner fa-spin fa-3x"></i><p style="margin-top: 20px;">Sorting internships...</p></div>';
    
    // AJAX request
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'sortInternships.jsp', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onload = function() {
        if(this.status === 200) {
            grid.innerHTML = this.responseText;
            
            const searchInput = document.getElementById('liveSearchInput');
            if(searchInput && searchInput.value.trim() !== '') {
                filterInternships(searchInput.value.toLowerCase().trim());
            }
        } else {
            grid.innerHTML = originalContent;
            alert('Error sorting internships. Please try again.');
        }
    };
    
    xhr.onerror = function() {
        grid.innerHTML = originalContent;
        alert('Network error. Please try again.');
    };
    
    xhr.send('sortBy=' + encodeURIComponent(sortBy));
}

function filterInternships(searchTerm) {
    const cards = document.querySelectorAll('.live-internship-card');
    let visibleCount = 0;
    
    cards.forEach(card => {
        const title = card.getAttribute('data-title') || '';
        const company = card.getAttribute('data-company') || '';
        const location = card.getAttribute('data-location') || '';
        const description = card.getAttribute('data-description') || '';
        
        const searchableText = (title + ' ' + company + ' ' + location + ' ' + description).toLowerCase();
        
        if(searchTerm === '' || searchableText.includes(searchTerm)) {
            card.style.display = 'flex';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    const resultsCount = document.getElementById('resultsCount');
    if(resultsCount) {
        resultsCount.textContent = `Showing ${visibleCount} of ${cards.length} internships`;
    }
    
    const grid = document.getElementById('internshipsGrid');
    const existingMsg = document.querySelector('.no-results-message');
    
    if(visibleCount === 0 && searchTerm !== '') {
        if(existingMsg) existingMsg.remove();
        
        const noResultsDiv = document.createElement('div');
        noResultsDiv.className = 'no-internships-message no-results-message';
        noResultsDiv.style.gridColumn = '1 / -1';
        noResultsDiv.innerHTML = `
            <i class="fas fa-search" style="font-size: 48px; margin-bottom: 20px; opacity: 0.5;"></i>
            <h3>No matching internships</h3>
            <p>Try searching with different keywords</p>
        `;
        grid.appendChild(noResultsDiv);
    } else {
        if(existingMsg) existingMsg.remove();
    }
}

function clearSearch() {
    const searchInput = document.getElementById('liveSearchInput');
    if(searchInput) {
        searchInput.value = '';
        filterInternships('');
        searchInput.focus();
        
        const clearBtn = document.getElementById('clearSearchBtn');
        const searchHeader = document.getElementById('searchResultsHeader');
        if(clearBtn) clearBtn.style.display = 'none';
        if(searchHeader) searchHeader.style.display = 'none';
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('liveSearchInput');
    const clearBtn = document.getElementById('clearSearchBtn');
    const searchHeader = document.getElementById('searchResultsHeader');
    
    if(searchInput) {
        searchInput.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase().trim();
            
            if(clearBtn) {
                clearBtn.style.display = searchTerm.length > 0 ? 'block' : 'none';
            }
            if(searchHeader && searchTerm.length > 0) {
                searchHeader.style.display = 'flex';
                const searchTermSpan = document.getElementById('searchTerm');
                if(searchTermSpan) searchTermSpan.textContent = searchTerm;
            } else if(searchHeader) {
                searchHeader.style.display = 'none';
            }
            
            filterInternships(searchTerm);
        });
    }
});