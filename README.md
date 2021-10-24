# Introduction #
Notejam applicaiton was first created as monolith and this project goal is to re-design it as microservice running on cloud. It would be more scalable, high available and automatically scale up/down with out-of-the-box networking and security integrations.The project consists of several steps:
1. Architecture
2. Developing
3. Preparing
4. Deployment
5. Setup CI/CD
# Architecture #
The new application would be containerized to run on `AWS` and use its kubernetes cluster technology `AWS EKS`, as it is the most trusted way to start, run and scal Kubernetes. At the end we are going to create an application that automatically scale up/down and run in a high availability configuraiotn.
* The applicaiton is now using `PostgreSQL` backend db instead  of `SQLite` for many reason. Ex: speed, functionality, realibiltiy..etc. However the most import feature that it is running as managed service on `AWS` and would be much easire for backup and retention.
* Initially the application is running on `EKS` three clustrs:
    - Development
    - Staging
    - Production




# Designing #
# Preparing #
# Deployment #
# Setup CI/CD #


