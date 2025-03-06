## Auth

This sub-application provides two key functionalities:

1. **Authentication behaviour and implementation**
   - Define and implemented callbacks need to be implemented to authenticate GraphQL API

2. **GenStage Pipeline for JWT Generation**
   - Processes all users in the database.
   - Generates **JWT tokens**.
   - Caches tokens in **ETS** for quick retrieval.

3. **JWT Creation and Validation**
   - Handles the **secure issuance and verification** of JWT tokens.

📂 **Diagrams:**  
Diagrams explaining **authentication** and **the token generation pipeline** can be found in the `docs` folder.
