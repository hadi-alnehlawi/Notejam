# Introduction #
Notejam applicaiton was first created as monolith and this project goal is to re-design it as microservice running on cloud. It would be more scalable, high available and automatically scale up/down with out-of-the-box networking and security integrations.The project consists of several steps:
1. Architecture
2. Developing
3. Preparing
4. Deployment
5. Setup CI/CD
# Architecture #
The new application would be containerized to run on AWS and use its kubernetes cluster technology **AWS EKS**, as it is the most trusted way to start, run and scal Kubernetes. At the end we are going to create an application that automatically scale up/down and run in a high availability configuraiotn.
* The applicaiton is now using **PostgreSQL** backend db instead  of **SQLite** for many reason, ex: speed, functionality, realibiltiy..etc. However the most import feature that it is running as managed service on `AWS` and would be much easire for backup and retention.
* Initially the application is running on `EKS` three clusters:
    - Development
    - Staging
    - Production
* Each cluster is connected to a load balancer `ELB`which in turns direct the connection to the app endpoints
* Autoscalling is configured to a production clustser that is supposedly configured to read the metric data of connection from prometheis and set the thredshold based on the noraml connection data time.
* DB is configured to set back-up policy 
# Developing #
# Preparing #
Building the infrastrcure is happening in an automated way using infrastrucre as code software tool - `Terraform`. The folder. The file `main.tf` build the following resource on AWS:
# Deployment #
# Setup CI/CD #


