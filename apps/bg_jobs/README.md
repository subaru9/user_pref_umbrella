## BgJobs

This sub-application runs **background jobs** using **Oban**. It has one worker responsible for:

1. **Node Status Monitoring**  
   - Every minute, the worker checks the status of all nodes.  

2. **Online Node Enumeration**  
   - Compiles a list of active nodes.  

3. **Metric Reporting**  
   - Sends collected data as a **metric** to be visualized in **Grafana**.  

Additionally, **UserPref** is configured as an **Oban failover node**. While other sub-apps can enqueue jobs, they will always be executed on this dedicated node.  

📂 **Diagrams:**  
The `docs` folder contains **architecture diagrams** explaining the system design and detailing all currently implemented **workers**.
