# Phase 1 – Provisioning an AWS EKS Cluster with Terraform

## Overview

In this phase we provisioned a complete Kubernetes environment on AWS using Terraform.  
The goal was to build a real, production-style EKS cluster including networking, security, and compute.

This phase creates the infrastructure layer on top of which applications will later run.

Terraform is used as Infrastructure-as-Code to ensure the environment is reproducible, versioned, and automated.

---

## What Was Built

Using Terraform we created:

• A VPC  
• Public and Private Subnets across multiple Availability Zones  
• Internet Gateway and Route Tables  
• IAM Roles for EKS  
• An EKS Control Plane  
• An EKS Node Group (worker EC2 instances)

Together these components form a full Kubernetes cluster running on AWS.

---

## Terraform Structure

The infrastructure is defined inside the `terraform/` folder:

terraform/
├── providers.tf
├── variables.tf
├── vpc.tf
├── eks.tf
├── backend.tf
├── outputs.tf


Each file is responsible for a different layer of the infrastructure (networking, cluster, IAM, etc).

---

## Initializing Terraform

Terraform is initialized with:

terraform init


This downloads all required providers and prepares the working directory.

---

## Creating the Infrastructure

To create the AWS environment:

terraform apply -auto-approve


Terraform then provisions all AWS resources including the EKS cluster and worker nodes.

---

## Verifying the Cluster

After Terraform completes, we verify the cluster exists:

aws eks list-clusters


Then we confirm the node group:

aws eks list-nodegroups --cluster-name marom-eks-cluster


This confirms that both the Kubernetes control plane and the worker nodes were created successfully.

---

## Result

At the end of Phase 1:

• A fully functional AWS EKS cluster exists  
• Worker nodes are attached  
• The cluster is ready to run Kubernetes workloads  

This completes the infrastructure foundation for the DevOps pipeline.

# Phase 2 – Dockerizing the Flask Application and Pushing to AWS ECR

## Overview

In this phase we took a local Flask application, packaged it into a Docker image, and pushed it into AWS Elastic Container Registry (ECR).  
This creates a production-ready artifact that Kubernetes (EKS) can later pull and run.

This phase connects application code to cloud infrastructure in a real DevOps flow:

Flask App → Docker Image → AWS ECR → Kubernetes (EKS)

This is exactly how modern production systems are deployed.

---

## Application Structure

The application is located inside the `app/` folder:



app/
├── app.py
├── requirements.txt
└── Dockerfile


The Flask app exposes HTTP on port 5000 and returns a simple response to confirm it is running.

---

## Building the Docker Image

From inside the `app` directory we build the Docker image:



docker build -t marom-app .


This creates a Docker image named `marom-app` that contains the Flask application and all of its dependencies.

---

## Running the Container Locally

To verify the image works:



docker run -p 5000:5000 marom-app


Open in browser:



http://localhost:5000


Expected output:



Hello from Marom's EKS DevOps App!


This confirms the container is running correctly.

---

## AWS ECR Repository

We created an ECR repository in AWS:



025707649967.dkr.ecr.us-east-1.amazonaws.com/marom-app


This repository is used to store production-grade Docker images.

---

## Logging in to AWS ECR

Before pushing images, Docker must authenticate to ECR:



aws ecr get-login-password --region us-east-1
| docker login --username AWS --password-stdin 025707649967.dkr.ecr.us-east-1.amazonaws.com


After this step, Docker is allowed to push images into AWS.

---

## Tagging the Image

The local image is tagged with the ECR repository URI:



docker tag marom-app:latest 025707649967.dkr.ecr.us-east-1.amazonaws.com/marom-app:latest


This tells Docker where the image should be uploaded.

---

## Pushing the Image to ECR



docker push 025707649967.dkr.ecr.us-east-1.amazonaws.com/marom-app:latest


The image is now stored inside AWS ECR and can be pulled by Kubernetes.

---

## Result

At the end of Phase 2:

• The Flask app is containerized  
• The Docker image is stored in AWS ECR  
• Kubernetes (EKS) can now deploy this image  

This completes the Docker & Registry layer of the DevOps pipeline and prepares the system for Kubernetes deployment in Phase 3.


# Phase 3 – Deploying the Application to EKS Using Helm

## Overview

In this phase we deploy the containerized Flask application into the EKS cluster using **Helm**.

Helm is used as a Kubernetes package manager that allows us to define, version, and manage application deployments in a clean and repeatable way.

This phase connects the infrastructure layer (EKS) with the application artifact (Docker image in ECR).

---

## Helm Chart Structure

The Helm chart is located under the `helm/` directory:

helm/
└── flask-app/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        └── service.yaml


Each file has a specific responsibility:

• `Chart.yaml` – Chart metadata  
• `values.yaml` – Configurable values (image, replicas, ports)  
• `deployment.yaml` – Kubernetes Deployment definition  
• `service.yaml` – Kubernetes Service definition  

---

## Kubernetes Deployment

The Deployment resource defines how the Flask application runs inside the cluster:

• Uses the Docker image stored in AWS ECR  
• Exposes port 5000 inside the container  
• Controls the number of running replicas  

The image repository and tag are injected using Helm values, allowing easy upgrades without changing manifests.

---

## Exposing the Application

The Service is defined as type **LoadBalancer**.

This instructs AWS to:

• Provision an external load balancer  
• Expose the application publicly  
• Route internet traffic to the Flask pods  

After deployment, the application becomes accessible from the internet via a public endpoint.

---

## Deploying with Helm

The application can be deployed using the following command:

helm upgrade --install flask-app ./helm/flask-app \
  --set image.repository=<ECR_REPOSITORY_URL> \
  --set image.tag=latest


Helm will:

• Create or update the Deployment  
• Create the Service  
• Roll out changes safely  

---

## Result

At the end of Phase 3:

• The Flask application is running on EKS  
• The application is exposed to the internet  
• Deployments are managed using Helm  

This completes the Kubernetes deployment layer of the system.

---

# Phase 4 – Automating Deployment with GitHub Actions

## Overview

In this phase we automate the full deployment process using **GitHub Actions**.

Every push to the `main` branch triggers a CI/CD pipeline that:

• Builds the Docker image  
• Pushes the image to AWS ECR  
• Deploys or updates the application in EKS using Helm  

This removes all manual steps and enables continuous delivery.

---

## GitHub Actions Workflow

The workflow file is located at:

.github/workflows/deploy.yaml


It defines a single pipeline triggered on pushes to the `main` branch.

---

## Pipeline Steps

The pipeline performs the following steps:

1. Checkout the repository code  
2. Configure AWS credentials using GitHub Secrets  
3. Authenticate Docker with AWS ECR  
4. Build the Flask Docker image  
5. Push the image to AWS ECR  
6. Deploy or update the application using Helm  

All sensitive values are stored securely using GitHub Secrets.

---

## Required GitHub Secrets

The following secrets must be configured in the GitHub repository:

• `AWS_ACCESS_KEY_ID`  
• `AWS_SECRET_ACCESS_KEY`  
• `ECR_REPOSITORY`  

These secrets allow the pipeline to authenticate with AWS and push images securely.

---

## Result

At the end of Phase 4:

• Docker images are built automatically  
• Images are pushed to AWS ECR  
• The application is deployed to EKS automatically  
• The system follows a full CI/CD workflow  

---

# Final Summary

This project demonstrates a complete DevOps pipeline:

• Infrastructure provisioning with Terraform  
• Application containerization with Docker  
• Kubernetes deployment using Helm  
• Continuous deployment using GitHub Actions  

All components follow infrastructure-as-code and automation best practices, creating a clean, reproducible, and production-style system.

