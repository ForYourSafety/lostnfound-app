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
            updateTagFilter();
        }
    });


    // Initialize the search input
    searchInput = document.getElementById('search_input');
    searchInput.value = search;
    const formOutline = searchInput.closest('.form-outline');
    const inputInstance = new mdb.Input(formOutline);
    inputInstance.update();

    searchInput.addEventListener('input', function() {
        updateSearchFilter();
    });

    updateTagFilter();
    updateSearchFilter();
}

function updateSearchFilter() {
    updateUrl();

    const searchValue = searchInput.value.toLowerCase();

    const items = document.querySelectorAll('.item-card');
    items.forEach(item => {
        const itemText = item.innerText.toLowerCase();
        const isVisible = itemText.includes(searchValue);
        item.style.display = isVisible ? 'block' : 'none';
    });
}

function updateTagFilter() {
    updateUrl();

    const selectedTags = tagSelect.selectedValues;

    const items = document.querySelectorAll('.item-card');
    items.forEach(item => {
        const itemTags = item.dataset.tags.split(',');
        const isVisible = selectedTags.length === 0 || itemTags.some(tag => selectedTags.includes(tag));
        item.style.display = isVisible ? 'block' : 'none';
    });
}

function updateUrl() {
    const selectedTags = tagSelect.selectedValues;

    const searchValue = searchInput.value.trim();

    const urlParams = new URLSearchParams();

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