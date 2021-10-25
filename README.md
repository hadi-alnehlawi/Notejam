# Introduction #
Notejam applicaiton was first created as monolith and this project goal is to re-design it as microservice running on cloud. It would be more scalable, high available and automatically scale up/down with out-of-the-box networking and security integrations.
## Technology Stack ##
We choose to run the applicaiton on AWS cloud providers for many factors. In my opinion, scalabiltiy and flexibility are the most important factors. In the below a list of AWS services stack:
* [Docker](https://www.docker.com/): We cannot think of microservice without mentioning docker. The whole concept of construct any microservice application is building it as contianers and the poineer technology to achiver this goal is Docker.
* [EKS](https://aws.amazon.com/eks/): It is the most trusted way to start, run and scal Kubernetes. At the end we are going to create an application that automatically scale up/down and run in a high availability configuraiotn.
* [RDS](https://aws.amazon.com/rds/?p=pm&c=db&z=3): Amazon Relational Database Service makes it easy to set up, operate, and scale a relational database in the cloud. It provides cost-efficient and resizable capacity while automating time-consuming administration tasks such as hardware provisioning, database setup, patching and backups.
* [Terraform](https://www.terraform.io/): Instead of provisioning the infrastrucre manually, I used terraform . Defining infrastrcue as code to create resources, manage existing ones, and destroy those no longer needed.
* [CircleCI](https://circleci.com): Continous Integration / Continous Development (CI/CD) is the most important tool to achive DevOps culture in developement any software. The hot label which could brief the benefit of CI/CD tool is *fail fast and repair fast*. One of the poineer tool is circleci to build a faster deployement jobs on robut cloud servers. Finally, have more than 100 developers to work in this project and who want to roll out multiple deployments a day without interruption / downtime would be impossible without using the CI/CD piplines.

The project consists of several steps with an acrynom for first five English letters **ABCDE**:
1. Architecture
2. Developing
3. Preparing
4. Deployment
5. Setup CI/CD
# Architecture #
The new application would be containerized to run on AWS and use its kubernetes cluster technology **AWS EKS**.
* The applicaiton is now using **PostgreSQL** backend db instead of SQLite for many reasons, ex: speed, functionality, realibiltiy..etc. However the most import feature that it is running as managed service on AWS and would be much easire for backup and retention.
* Initially the application is running on **AWS EKS** three clusters:
    - Development
    - Staging
    - Production
* Each cluster is connected to a load balancer **AWS ELB** which in turns direct the connection to the app endpoints
* Autoscalling is configured to a production clustser that is supposedly configured to read the metric data of connection from prometheis and set the thredshold based on the noraml connection data time.
* The DB snapshot data is exported to a S3 called `ntoejam-db-backup` by lambda function to run for example every day.
* This bucket has a lifecyle period for 3 years.
# Building #
Building the infrastrcure is happening in an automated way using infrastrucre as code software tool - **Terraform**:
``` 
$ cd ./infrastrcure
$ terraform init
$ terraform plan main.tf -var-file variables.tfvars
$ terraform apply -var-file variables.tfvars
```
The above commands build the whole infrastrucre which is needed to have the applicaiton up and running. The resources are:
* VPC 
* RDS - postgres database
* S3 Bucket - to store the db backup files for 3 years 
* EKS Clusters - three k8s clusters: developments - staging - produciton
# Creating #
# Deployment #
# Establish #




