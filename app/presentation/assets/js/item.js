
document.addEventListener('DOMContentLoaded', function() {
    setupDeleteForm();
});

function setupDeleteForm() {
    const deleteForm = document.getElementById('delete-form');
    if (deleteForm) {
        deleteForm.addEventListener('submit', function(event) {
            event.preventDefault();
            if (confirm('Are you sure you want to delete this item?')) {
                deleteForm.submit();
            }
        });
    }
}