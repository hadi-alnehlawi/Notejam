# Introduction #
Notejam applicaiton was first created as monolith and this project goal is to re-design it as microservice running on cloud. It would be more scalable, high available and automatically scale up/down with out-of-the-box networking and security integrations.
### Technology Stack ###
We choose to run the applicaiton on AWS cloud providers for many factors. In my opinion, scalabiltiy and flexibility are the most important factors. In the below a list of AWS services and DevOps tools used in the project:
* [Docker](https://www.docker.com/): We cannot think of microservice without mentioning docker. The whole concept of construct any microservice application is building it as contianers and the poineer technology to achiver this goal is Docker.
* [EKS](https://aws.amazon.com/eks/): It is the most trusted way to start, run and scal Kubernetes. At the end we are going to create an application that automatically scale up/down and run in a high availability configuraiotn.
* [RDS](https://aws.amazon.com/rds/?p=pm&c=db&z=3): Amazon Relational Database Service makes it easy to set up, operate, and scale a relational database in the cloud. It provides cost-efficient and resizable capacity while automating time-consuming administration tasks such as hardware provisioning, database setup, patching and backups.
* [Lambda](https://aws.amazon.com/lambda): Two Amazon Lambda functions are used to execute servlesss jobs. First one to take a manual snap shot of the database and the second one to export the snapt shot into S3bucket.
* [S3 Bucket](https://aws.amazon.com/s3): Storing the db snapeshot for three years and set an autoamtic cleanup policy to delete overdue objects. 
* [Terraform](https://www.terraform.io/): Instead of provisioning the infrastrucre manually, I used terraform . Defining infrastrcue as code to create resources, manage existing ones, and destroy those no longer needed.
* [CircleCI](https://circleci.com): Continous Integration / Continous Development (CI/CD) is the most important tool to achive DevOps culture in developement any software. The hot label which could brief the benefit of CI/CD tool is *fail fast and repair fast*. One of the poineer tool is circleci to build a faster deployement jobs on robut cloud servers. Finally, have more than 100 developers to work in this project and who want to roll out multiple deployments a day without interruption / downtime would be impossible without using the CI/CD piplines.

The project consists of several steps with an acrynom for the first-five English letters **ABCDE**:
1. **A**rchitecting
2. **B**uilding
3. **C**reating
4. **D**eploying
5. **E**stablishing
# Architecting #
Cluster
![Alt text](./cluster.jpeg?raw=true "Title")

Database Backup
![Alt text](./backup.jpeg?raw=true "Title")
The new application would be containerized to run on AWS and use its kubernetes cluster technology **AWS EKS**.
* The applicaiton is now using **PostgreSQL** backend db instead of SQLite for many reasons, ex: speed, functionality, realibiltiy..etc. However the most import feature that it is running as managed service on AWS and would be much easire for backup and retention.
* Initially the application is running on three EKS clusters:
    - Development
    - Staging
    - Production
* Each cluster is connected to a load balancer **AWS ELB** which in turns direct the connection to the app endpoints.
* To achive the goal of high availability of the application during the peek and hight load times, two concepts of scalling has been implmented on the deployments:
    - Horizaonla Pod Autoscaler: increase the number of replicas of the pods based on the resource utilizations.
    - Cluster Autosclaer: automatically adjust the size of K8S clusters so all pods can scale and run successfully on its nodes.
The Application must serve variable amount of traffic. Most users are active during business hours. During big
events and conferences the traffic could be 4 times more than typical.
* Autoscalling is configured to a production clustser that is supposedly configured to read the metric data of connection from prometheis and set the thredshold based on the noraml connection data time.
* A **lambda function** is triggered by a **EventBridge** on a specific time (Daily at 12 AM UTC) to create a snapshot of the database.
* Once the sanpshort is created, another lambda function is triggerd as well by EventBridge and export it to a **S3 bucket** called `notejamsnapshot`.
* This bucket has a lifecyle period for 3 years.
# Building #
Building the infrastrcure is happening in an automated way using infrastrucre as code software tool - **Terraform**
Before run we need to create a vairable file and map the its value. In additional to Terraform , we need a tool called [eksctl](https://eksctl.io/) which is going to be used to create kubernete cluster on aws easily and fast:

**EKS Clustsers**
```
$ ## development
$ eksctl create -f ./infrastructure/eks/cluster-development.yaml
$ ## staging
$ eksctl create -f ./infrastructure/eks/cluster-staging.yaml
$ ## proudciton
$ eksctl create -f ./infrastructure/eks/cluster-production.yaml
$ ## list clusters 
$ eksctl get clusters
``` 

**AWS Resources**
```
$ cd ./infrastrcure/terraform
$ touch variables.tfvars
$ ## fill the values identified from the file variables.tf
$ terraform init
$ terraform plan -var-file variables.tfvars
$ terraform apply -auto-approve -var-file variables.tfvars
```
The above commands build the whole infrastructure which is needed to have the applicaiton up and running. The resources are:
* VPC - virtual private cloud on aws for network backbone.
* RDS - postgres database.
* S3 Bucket - store the db backup files for 3 years.
* Lambda Functions - take database snapshots and export it to s3 bucket.
* EKS Clusters - three k8s clusters: developments - staging - produciton.
# Creating #
This building step would be part of a **Continuous Integation** pipeline. We are going to build the application to run on k8s cluster. In other words, build the appilcation as a contianer and push it to a registery:
* The file `Dockerfile` is created to contains all the commands to be executed to build the container.
* Database URL is configured in as environement varaiable as `ENV {DB_URI}` which created in build step.
* We can test the container applicaiton by update the `ENV` and the runn the command
```
$ cd app
$ export POSTGRES_HOST=your_aws_rds_uri
$ export DB_URI="postgresql://postgres:postgres@$POSTGRES_HOST/postgres"
$ docker build -t notejam .
$ docker run -it --network host -p 5000 -e DB_URI=$DB_URI notejam
```
* One we successfully build the docker image we need to push into any contianer registery, ex [docker hub](https://hub.docker.com), it will be used to build the deployment in the next step. 
* There is a possibility to use any other regstier other than dockerhub. ex: [ECS](https://aws.amazon.com/ecr/).
```
$ export password="dockerhub_password" && user="dockerhub_username" && name="dockerhub_name"
$ echo "$password" | docker login -u "user" --password-stdin
$ docker tag notejam $name/notejam:latest
$ docker push $name/notejam:latest
```
# Deploying #
## Application ##
* Install the helm chart tempalte `notejamehelm` into our new produciton cluster.
```
$ helm install notejamhelm ./deployment/notejamhelm
$ kubectl get deployments 
## NAME      READY   UP-TO-DATE   AVAILABLE   AGE
## notejam   1/1     1            1           4m24s
```
* Repeat the same commnad for each cluster **staging** and **development**.
## Auto Scale ##
```
$ kubectl autoscale deployment notejam `#The target average CPU utilization` \
    --cpu-percent=50 \
    --min=3 `#The lower limit for the number of pods that can be set by the autoscaler` \
    --max=10 `#The upper limit for the number of pods that can be set by the autoscaler`
```

# Establishing #




