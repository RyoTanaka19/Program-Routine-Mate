import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="autocomplete"
export default class extends Controller {
  // `url` value is the URL to fetch autocomplete results from
  static values = { url: String };
  // `results` is the target where the autocomplete results will be displayed
  static targets = ['results'];

  // Triggered when the user types in the search input
  search(event) {
    const query = encodeURIComponent(event.target.value); // Get the search query
    const url = `${this.urlValue}?q[content_cont]=${query}`; // Construct the search URL with query parameters

    // Fetch the autocomplete results from the server
    fetch(url)
      .then((response) => response.json())
      .then((data) => {
        this.updateResults(data); // Update the results in the UI with the fetched data
      })
      .catch((error) => {
        console.error('Error fetching autocomplete data:', error); // Log any errors to the console
        this.showError(); // Show error message to user
      });
  }

  // Update the results section with the fetched data
  updateResults(data) {
    this.resultsTarget.innerHTML = ''; // Clear previous results

    if (data.length === 0) {
      this.showNoResultsMessage(); // Show a message if no results are found
      return;
    }

    // Loop through each item in the data and create a list item for it
    data.forEach((item) => {
      const li = document.createElement('li');
      li.textContent = item.content; // Set the text of the list item to the content
      li.classList.add('cursor-pointer', 'hover:bg-blue-100', 'px-4', 'py-2'); // Add some styles for interactivity

      // Add click event to select the result
      li.addEventListener('click', () => {
        this.selectResult(item); // When an item is clicked, select it
      });

      this.resultsTarget.appendChild(li); // Append the list item to the results
    });
  }

  // Select a result when it's clicked and populate the input with the selected content
  selectResult(item) {
    const input = this.element.querySelector('input'); // Find the input field
    input.value = item.content; // Set the value of the input to the selected item's content

    this.resultsTarget.innerHTML = ''; // Clear the results once a selection is made
  }

  // Show a message when there are no results found
  showNoResultsMessage() {
    const message = document.createElement('li');
    message.textContent = '該当する結果はありません。';
    message.classList.add('text-gray-500', 'px-4', 'py-2'); // Add styling for the no-results message
    this.resultsTarget.appendChild(message);
  }

  // Show an error message to the user if the fetch fails
  showError() {
    const message = document.createElement('li');
    message.textContent =
      'データの取得に失敗しました。もう一度お試しください。';
    message.classList.add('text-red-500', 'px-4', 'py-2'); // Styling for the error message
    this.resultsTarget.appendChild(message);
  }
}
