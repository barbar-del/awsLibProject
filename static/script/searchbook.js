document.addEventListener('DOMContentLoaded', function() {
    const searchForm = document.querySelector('form');
    const bookList = document.querySelector('.book-list');
  
    searchForm.addEventListener('submit', function(event) {
      event.preventDefault(); // Prevent default form submission
      console.log(genre);
      const formData = new FormData(searchForm);
      fetch(`/rent/${encodeURIComponent(searchForm.elements.email.value)}`, {
        method: 'POST',
        body: formData
      })
      .then(response => response.json())
      .then(data => {
        // Clear the current book list
        bookList.innerHTML = '';
  
        // Populate the book list with search results
        data.books.forEach(book => {
          const option = document.createElement('option');
          option.value = book.book_id;
          option.textContent = `${book.book_name} - ${book.book_author_name}`;
          bookList.appendChild(option);
        });
      })
      .catch(error => {
        console.error('Error:', error);
      });
    });
  });