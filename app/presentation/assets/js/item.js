
document.addEventListener('DOMContentLoaded', function() {
    setupDeleteForm();
    setupResolveForm();
});

function setupDeleteForm() {
    const deleteForm = document.getElementById('delete-form');
    if (deleteForm) {
        deleteForm.addEventListener('submit', function(event) {
            event.preventDefault();

            message = "Are you sure you want to delete this item? This action cannot be undone."
            if (confirm(message)) {
                deleteForm.submit();
            }
        });
    }
}

function setupResolveForm() {
    const resolveForm = document.getElementById('resolve-form');
    if (resolveForm) {
        resolveForm.addEventListener('submit', function(event) {
            event.preventDefault();
            message = "Are you sure you want to resolve this item? This action cannot be undone."
            message += `\nAfter resolving, contact requesters can no longer see your contacts, and the item will be hidden from the items list.`;

            if (confirm(message)) {
                resolveForm.submit();
            }
        });
    }
}