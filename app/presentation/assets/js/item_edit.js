document.addEventListener('DOMContentLoaded', function() {
    setupTypeSelection();
    setupContactInput();
    setupFilePond();
    setupDateTimePicker();
    setupTagSelect();
    setupImageDeleteButton();
    setupSubmitButton();
});

function setupTypeSelection() {
    itemType = document.getElementById('current-type').dataset.type;

    typeLost = document.getElementById('type-lost');
    typeFound = document.getElementById('type-found');

    ownerInfoDiv = document.getElementById('owner-info');

    locationLabel = document.getElementById('location-label');
    itemTimeElem = document.getElementById('item-time');

    instructionsElem = document.getElementById('instructions');

    updateType();

    typeLost.addEventListener('click', function() {
        itemType = 'lost';
        updateType();
    });

    typeFound.addEventListener('click', function() {
        itemType = 'found';
        updateType();
    });
}

function updateType() {
    typeLost.classList.toggle('badge-danger', itemType === 'lost');
    typeLost.classList.toggle('badge-light', itemType !== 'lost');
    typeFound.classList.toggle('badge-success', itemType === 'found');
    typeFound.classList.toggle('badge-light', itemType !== 'found');
    
    locationLabel.innerText = itemType === 'lost' ?
        'Where was it lost?' :
        'Where was it found?';
    
    itemTimeElem.placeholder = itemType === 'lost' ?
        'Approximately when was it lost?' :
        'Approximately when was it found?';
}

function setupTagSelect() {
   tagSelectElem = document.getElementById('tag-select');

    // Initialize the multi-select
    tagSelect = new MultiSelect(tagSelectElem, {
        placeholder: 'Add tags...',
        selectAll: false
    });
}



function setupContactInput() {
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

    const deleteContactButtons = document.getElementsByClassName('delete-contact-button');
    for (let i = 0; i < deleteContactButtons.length; i++) {
        deleteContactButtons[i].addEventListener('click', function() {
            const contactEntry = this.closest('.contact-entry');
            contactList.removeChild(contactEntry);
        });
    }
}

function setupImageDeleteButton() {
    const deleteImageButtons = document.getElementsByClassName('delete-image-button');
    for (let i = 0; i < deleteImageButtons.length; i++) {
        deleteImageButtons[i].addEventListener('click', function() {
            const imageEntry = this.closest('.existing-image');
            imageEntry.remove();
        });
    }
}

function setupDateTimePicker() {
    const locale = {
        days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
        daysShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        daysMin: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
        months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        today: 'Today',
        clear: 'Clear',
        dateFormat: 'yyyy/MM/dd',
        timeFormat: 'hh:mm AA',
        firstDay: 0
    };

    new AirDatepicker('#item-time', {
        inline: true,
        timepicker: true,
        locale: locale
    });
}


function setupFilePond() {
    FilePond.registerPlugin(
        FilePondPluginImagePreview,
        FilePondPluginFileValidateType,
    );

    imageFileUpload = FilePond.create(
        document.getElementById('image-upload'), {
            acceptedFileTypes: ['image/*']
        }
    );

    console.log('FilePond initialized');
}

function setupSubmitButton() {
    const submitButton = document.getElementById('submit-button');
    submitButton.addEventListener('click', function(event) {
        event.preventDefault(); // Prevent the default form submission

        submitForm()
    });
}

function submitForm() {
    // Validate the form
    const form = document.getElementById('item-form');
    if (!form.checkValidity()) {
        form.reportValidity();
        return false;
    }

    // Get field values
    const itemName = document.getElementById('item-name').value;
    const itemDescription = document.getElementById('item-description').value;
    const itemLocation = document.getElementById('item-location').value;
    const itemTime = document.getElementById('item-time').value;
    const challengeQuestion = document.getElementById('challenge-question').value;
    const itemTags = tagSelect.selectedValues;

    const existingImages = Array.from(document.querySelectorAll('.existing-image')).map(elem => elem.dataset.key);
    const images = imageFileUpload.getFiles().map(file => file.file);

    const contacts = Array.from(document.querySelectorAll('.contact-entry')).map(entry => {
        const type = entry.querySelector('.contact-type').value;
        const value = entry.querySelector('.contact-value').value;
        return { type, value };
    });

    // yyyy/MM/dd hh:mm AA
    const timestamp = new Date(itemTime).getTime();

    // Create the form data
    const formData = new FormData();
    formData.append('name', itemName);

    if (itemDescription.trim() !== '')
        formData.append('description', itemDescription);

    if (itemLocation.trim() !== '')
        formData.append('location', itemLocation);

    if (timestamp)
        formData.append('time', timestamp / 1000); // Convert to seconds
    
    if (challengeQuestion.trim() !== '')
        formData.append('challenge_question', challengeQuestion);

    if (itemType)
        formData.append('type', itemType);

    itemTags.forEach((tag, index) => {
        formData.append('tags[]', tag);
    });

    existingImages.forEach((image, index) => {
        formData.append('existing_images[]', image);
    });

    images.forEach((image, index) => {
        formData.append('images[]', image);
    });
    
    contacts.forEach((contact, index) => {
        formData.append('contact_type[]', contact.type);
        formData.append('contact_value[]', contact.value);
    });

    const loadingModalElem = document.getElementById('loading-modal');
    loadingModal = new mdb.Modal(loadingModalElem);

    loadingModal.show();

    // Send the form data to the same URL as the current page
    fetch(window.location.href, {
        method: 'POST',
        body: formData
    })
    .then(async response => {
        if (response.ok) {
            res = await response.json();
            console.log(res);

            item_id = res.data.attributes.id;
            window.location.href = `/items/${item_id}`;
        } else {
            res = await response.json();
            console.error('Error:', res);

            const errorBar = document.getElementById('error-bar');
            errorBar.innerText = res.message || 'An error occurred while submitting the form.';
            errorBar.classList.remove('d-none');
            errorBar.classList.add('d-block');

            setTimeout(() => {
                loadingModal.hide();
            }, 500);
        }
    });
}

