
document.addEventListener('DOMContentLoaded', function() {
    setupDeleteButton();
});

function setupDeleteButton() {
    const deleteButton = document.getElementById('delete-item');
    if (deleteButton) {
        deleteButton.addEventListener('click', function() {
            const confirmation = confirm('Are you sure you want to delete this item?');
            if (confirmation) {
                const itemId = deleteButton.getAttribute('data-item-id');
                fetch(`/items/${itemId}`, {
                    method: 'DELETE'
                })
                .then(response => {
                    if (response.ok) {
                        window.location.href = '/items';
                    }
                })
                .catch(error => {
                    console.error('Error deleting item:', error);
                    alert('An error occurred while trying to delete the item.');
                });
            }
        });
    }
}