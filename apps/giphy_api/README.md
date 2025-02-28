## GiphyAPI

This sub-application interacts with the **Giphy API** to fetch GIFs based on a search query. It operates as follows:

1. **Asynchronous API Requests**  
   - Uses a query word to spawn multiple **supervised but unlinked asynchronous tasks**.  
   - Each task sends a request to the **Giphy API**.  

2. **Result Consolidation**  
   - Collects responses from all tasks.  
   - Merges them into a **single structured result**.  

3. **JSON Decoding with Elixir’s Native Support**  
   - Processes the final response using **Elixir’s built-in JSON functionality**.  
