## UserPrefWeb

This sub-application serves as the **GraphQL API layer** and includes various performance and security enhancements.

1. **GraphQL API Implementation**  
   - Provides a set of **queries and mutations**, including fetching the **current user**, and **subscriptions**.  

2. **Resolver Hits Counter**  
   - Tracks how many times a resolver is accessed.  
   - Caches the count in an **OTP Agent**.  
   - Emits **Prometheus metrics**, which are later visualized in **Grafana**.  

3. **Authenticated Mutations**  
   - Extracts **JWT tokens** from the **Authorization header** using an authentication plug.  
   - Stores the token in **Absinthe’s context** for validation in **Absinthe middleware**.  

4. **Early Request Caching**  
   - Uses **request_cache** with a **Redis backend** to **cache incoming requests before they reach the router**.  

5. **Telemetry and Metrics**  
   - Sends various **GraphQL-related telemetry data** to **Prometheus**.  
   - Data is later pulled into **Grafana** for **real-time monitoring**.  

📂 **Diagrams:**  
The `docs` folder contains diagrams showcasing **user creation** and **serving workflows**.  
