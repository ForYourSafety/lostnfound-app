window.onload = () => {
    // Get filters from url
    const urlParams = new URLSearchParams(window.location.search);

    tagSelectElem = document.getElementById('tag-select');

    // Initialize the multi-select
    tagSelect = new MultiSelect(tagSelectElem, {
        placeholder: 'Add tags...',
        selectAll: false
    });


    typeLost = document.getElementById('type-lost');
    typeFound = document.getElementById('type-found');

    typeFilter = urlParams.get('type') || 'found';
    updateTypeStyle();

    typeLost.addEventListener('click', function() {
        typeFilter = 'lost';
        updateTypeStyle();
    });

    typeFound.addEventListener('click', function() {
        typeFilter = 'found';
        updateTypeStyle();
    });
}

function updateTypeStyle() {
    typeLost.classList.toggle('badge-danger', typeFilter === 'lost');
    typeLost.classList.toggle('badge-light', typeFilter !== 'lost');
    typeFound.classList.toggle('badge-success', typeFilter === 'found');
    typeFound.classList.toggle('badge-light', typeFilter !== 'found');
}


function updateUrl() {
    const urlParams = new URLSearchParams();

    urlParams.set('type', typeFilter);

    const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
    window.history.pushState({ path: newUrl }, '', newUrl);
}

document.addEventListener('DOMContentLoaded', function() {
    const addContactButton = document.getElementById('add-contact-button');
    const addContactEntry = document.getElementById('add-contact-entry');
    const contactList = document.getElementById('contact-list');
    const addContactInput = addContactEntry.querySelector('#add-contact-value');

    function validateContactInput(input) {
        const value = input.value.trim();
        if (value.trim() === '') {
            input.classList.add('is-invalid');
            return false;
        }

        input.classList.remove('is-invalid');
        return true;
    }

    addContactInput.addEventListener('input', function(event) {
        validateContactInput(event.target);
    });

    addContactButton.addEventListener('click', function() {
        // Clone the contact entry
        const newContactEntry = addContactEntry.cloneNode(true);

        // Get the values
        const select = addContactEntry.querySelector('#add-contact-type');
        const selectValue = select.value;
        const input = addContactEntry.querySelector('#add-contact-value');
        const inputValue = input.value;

        // Validate the input value
        if (!validateContactInput(input)) {
            return; // Do not proceed if the input is invalid
        }

        // Clear the values
        select.value = 'email';
        input.value = '';

        // Set the input value of the new entry
        const newSelect = newContactEntry.querySelector('#add-contact-type');
        newSelect.value = selectValue;
        const newInput = newContactEntry.querySelector('#add-contact-value');
        newInput.value = inputValue;

        // Clear the IDs
        newContactEntry.removeAttribute('id');
        newSelect.removeAttribute('id');
        newInput.removeAttribute('id');
        const button = newContactEntry.querySelector('button');
        button.removeAttribute('id');

        // Change the button appearance
        button.classList.remove('btn-success');
        button.classList.add('btn-danger');
        button.innerHTML = '<i class="fas fa-minus"></i>';

        // Append the new entry to the contact list
        contactList.appendChild(newContactEntry);

        // Add event listener to the minus button
        button.addEventListener('click', function() {
            contactList.removeChild(newContactEntry);
        });
        // Add event listener to the new input
        newInput.addEventListener('input', function(event) {
            validateContactInput(event.target);
        });
    });
});
