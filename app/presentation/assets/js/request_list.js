
document.addEventListener('DOMContentLoaded', function() {
    setupStatusFilter();
    setupSearchFilter();

    updateFilters();
});

function setupStatusFilter() {
    const urlParams = new URLSearchParams(window.location.search);
    statusFilter = urlParams.get('status') || '';

    statusUnanswered = document.getElementById('status-unanswered');
    statusApproved = document.getElementById('status-approved');
    statusDeclined = document.getElementById('status-declined');

    updateStatusStyle();

    statusUnanswered.addEventListener('click', function() {
        statusFilter = statusFilter === 'unanswered' ? '' : 'unanswered';
        updateStatusStyle();
        updateFilters();
    });

    statusApproved.addEventListener('click', function() {
        statusFilter = statusFilter === 'approved' ? '' : 'approved';
        updateStatusStyle();
        updateFilters();
    });

    statusDeclined.addEventListener('click', function() {
        statusFilter = statusFilter === 'declined' ? '' : 'declined';
        updateStatusStyle();
        updateFilters();
    });
}

function updateStatusStyle() {
    statusUnanswered.classList.toggle('badge-dark', statusFilter === 'unanswered');
    statusUnanswered.classList.toggle('badge-light', statusFilter !== 'unanswered');
    statusApproved.classList.toggle('badge-success', statusFilter === 'approved');
    statusApproved.classList.toggle('badge-light', statusFilter !== 'approved');
    statusDeclined.classList.toggle('badge-danger', statusFilter === 'declined');
    statusDeclined.classList.toggle('badge-light', statusFilter !== 'declined');
}


function setupSearchFilter() {
    const urlParams = new URLSearchParams(window.location.search);
    search = urlParams.get('search') || '';

    searchInput = document.getElementById('search_input');
    searchInput.value = search;
    const formOutline = searchInput.closest('.form-outline');
    const inputInstance = new mdb.Input(formOutline);
    inputInstance.update();

    searchInput.addEventListener('input', function() {
        updateFilters();
    });
}

function updateFilters() {
    updateUrl();

    const requests = document.querySelectorAll('.request-card');
    requests.forEach(function(request) {
        const isVisible = searchVisible(request) && statusVisible(request);
        request.style.display = isVisible ? 'block' : 'none';
    });
}

function statusVisible(request) {
    if (!statusFilter) return true; // No filter applied, show all

    const status = request.getAttribute('data-status');
    return status === statusFilter;
}

function searchVisible(request) {
    const searchValue = searchInput.value.toLowerCase();
    const requestText = request.innerText.toLowerCase();
    return requestText.includes(searchValue);
}

function updateUrl() {
    const searchValue = searchInput.value.trim();

    const urlParams = new URLSearchParams();

    // Add the status filter to the URL parameters
    if (statusFilter) {
        urlParams.set('status', statusFilter);
    }

    // Update the search parameter
    if (searchValue) {
        urlParams.set('search', searchValue);
    }

    const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
    window.history.pushState({ path: newUrl }, '', newUrl);
}