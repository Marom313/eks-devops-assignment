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
