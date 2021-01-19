# GCP DevOps Accelerator - Hashicorp Stack

Looking for toolkits to accelerate your journey adopting Google Cloud Platform? Congrats! you are at the right place to start.

With the combination of a list of repositories and following the instructions in the README files, you will setup a series of pipelines and corresopnding processes which forms a robust CICD Platform targeting at Google Cloud Platform. The entire practice will take roughly xx hours.

Before start, all instructions assume you have a good understanding of GCP Concepts, especially cloudbuild, and Hashicorp Stack e.g. Terraform.

## Getting Started

The development journey are break down into three key steps:
1. GCP Pipeline Bootstrap for Tool Stack
2. GCP Terraform Module Setup
3. GCP Terraform Foundation Provision
4. *Packer 

This instructure will mainly focus on step 1 - GCP Pipeline Bootstrap

### Prerequisites

1. GCP Project with Billing Enabled (Free tier should also be fine)
2. Project Owner Access to the Project 
3. All github repos for DevOps Accelerator are either forked or cloned to your own workspace

### Bootstrapping

Following the below steps you will:
1. Configure target GCP Project
2. Enable all required Gcloud service APIs
3. Create Storage bucket for Terraform statefile backend
4. Enable Storage bucket versioning
5. Grant Cloudbuild Service Account access to the Storage bucket
6. Create Cloudbuild triggers for GCP Pipeline bootstrap
7. Create Cloudbuild triggers for GCP Modules Build

### Installation

1. Update GCP Bootstrap metadata - terraform-gcp-bootstrap/bin/boostrap.yaml

```
BUILD_PROJECT_ID: Your Project ID
BOOTSTRAP_REPO_NAME: terraform-gcp-bootstrap
MODULE_REPO_NAME: terraform-gcp-module
REPO_OWNER: Your Github Account ID for forked/cloned terraform repos
```

2. Run bootstrap.sh 

```
$ ./bin/bootstrap.sh
```

### Validation

