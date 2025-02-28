## SharedUtils

This sub-application provides **shared utilities** for caching and JSON handling. It includes:

1. **Cacheable Behavior**  
   - A reusable **behavior** that defines **callbacks** commonly used when interacting with a cache.  

2. **Multiple Cache Implementations**  
   - Three concrete implementations using **Agents, ETS, and GenServer**.  

3. **Redis Cache Utility**  
   - A specialized utility that **implements the Cacheable Behavior** for **Redis**.  

4. **JSON Decoding**  
   - A utility for **JSON parsing**, leveraging **Elixir’s native JSON support**.  
