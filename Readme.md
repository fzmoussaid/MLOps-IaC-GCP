# Deploy an ML model in GCP using Docker and Kubernetes

This repository contains the source for creating the infrastructure to deploy an ML model in Google Cloud Platform. Here we deploy a fastapi app to make predictions on simple binary classification model, but the source code itself can be used to deploy any REST API you want to deploy on GCP.

## Source code:

`main.tf`: Sets up GKE Cluster and VPC.

`app.tf`: Deploys the app in a Kubernetes pod and exposes it as a load balancer.

## Prior work:

#### GCP:

1. Follow the instructions in [this page](https://cloud.google.com/sdk/docs/install#linux) to install gcloud. Install on local machine or use google cloud shell where gcloud is already set up.

2. Follow the instructions in [this page](https://cloud.google.com/resource-manager/docs/creating-managing-projects) to create a project in Google Cloud.

3. Run `gcloud config set project [your_project_id]` to set up GCP project.

4. Run `gcloud auth login` to authenticate with GCP.

5. Run `gcloud container clusters get-credentials [your-cluster-name] --region=[your-region]` to authenticate to GKE cluster.

#### Terraform:

Follow the instructions in [this page](https://www.terraform.io/downloads) to install terraform.

#### Your app:

1. Run `docker build -t [your-gcp-region].pkg.dev/[your-project-name]/[your-registry-name]/[your-image-name]:[your-tag] .` to containerize your app using docker.

2. Run `docker push [your-gcp-region].pkg.dev/[your-project-name]/[your-registry-name]/[your-image-name]:[your-tag]` to upload your image to google artifact registry.

## Build the infrastructure and Deploy the ML model:

1. Run `terraform init` to initiate terraform project.

2. Run `terraform plan` to plan infrastructure building. This command will show you the resources that will be created/updated/deleted in GCP.

3. Run `terraform apply` to actually build the infrastructure defined in terraform configuration files.
