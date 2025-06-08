window.onload = () => {
    // Get filters from url
    const urlParams = new URLSearchParams(window.location.search);
    tagFilters = urlParams.getAll('tag');
    search = urlParams.get('search') || '';

    // Select the options in the multi-select based on the URL parameters
    tagSelectElem = document.getElementById('tag-filter');
    const options = tagSelectElem.querySelectorAll('option');
    options.forEach(option => {
        if (tagFilters.includes(option.value)) {
            option.selected = true;
        }
    });

    // Initialize the multi-select with the selected options
    tagSelect = new MultiSelect(tagSelectElem, {
        placeholder: 'Filter by tags',
        onChange: function(value, text, element) {
            updateFilters();
        }
    });


    // Initialize the search input
    searchInput = document.getElementById('search_input');
    searchInput.value = search;
    const formOutline = searchInput.closest('.form-outline');
    const inputInstance = new mdb.Input(formOutline);
    inputInstance.update();

    searchInput.addEventListener('input', function() {
        updateFilters();
    });

    typeLost = document.getElementById('type-lost');
    typeFound = document.getElementById('type-found');

    typeFilter = urlParams.get('type') || '';
    updateTypeStyle();

    typeLost.addEventListener('click', function() {
        typeFilter = typeFilter === 'lost' ? '' : 'lost';
        updateTypeStyle();
        updateFilters();
    });

    typeFound.addEventListener('click', function() {
        typeFilter = typeFilter === 'found' ? '' : 'found';
        updateTypeStyle();
        updateFilters();
    });

    updateFilters();

    // Add event listener for new item button
    const newItemButton = document.getElementById('new-item-button');
    if (newItemButton) {
        newItemButton.addEventListener('click', function() {
            newType = typeFilter || 'found'; // Default to 'found' if no type is selected
            window.location.href = '/items/new?type=' + typeFilter;
        });
    }
}

function updateTypeStyle() {
    typeLost.classList.toggle('badge-danger', typeFilter === 'lost');
    typeLost.classList.toggle('badge-light', typeFilter !== 'lost');
    typeFound.classList.toggle('badge-success', typeFilter === 'found');
    typeFound.classList.toggle('badge-light', typeFilter !== 'found');
}

function searchVisible(item) {
    const searchValue = searchInput.value.toLowerCase();
    const itemText = item.innerText.toLowerCase();
    return itemText.includes(searchValue);
}

function tagVisible(item) {
    const selectedTags = tagSelect.selectedValues;
    const itemTags = item.dataset.tags.split(',');
    return selectedTags.length === 0 || itemTags.some(tag => selectedTags.includes(tag));
}

function typeVisible(item) {
    const itemType = item.dataset.type;
    if (!typeFilter)
        return true; // If no type filter is set, show all items
    return itemType === typeFilter;
}

function updateFilters() {
    updateUrl();

    const items = document.querySelectorAll('.item-card');
    items.forEach(item => {
        const isSearchVisible = searchVisible(item);
        const isTagVisible = tagVisible(item);
        const isTypeVisible = typeVisible(item);

        if (isSearchVisible && isTagVisible && isTypeVisible) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
}

function updateUrl() {
    const selectedTags = tagSelect.selectedValues;

    const searchValue = searchInput.value.trim();

    const urlParams = new URLSearchParams();

    // Add the type filter to the URL parameters
    if (typeFilter) {
        urlParams.set('type', typeFilter);
    }

    // Update the search parameter
    if (searchValue) {
        urlParams.set('search', searchValue);
    }

    // Add the selected tags to the URL parameters
    selectedTags.forEach(tag => {
        urlParams.append('tag', tag);
    });

    const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
    window.history.pushState({ path: newUrl }, '', newUrl);
}