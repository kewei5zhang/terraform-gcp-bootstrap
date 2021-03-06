#!/bin/bash
# set -x

#BUILD_PROJECT_ID="kewei-demo-sandbox"
#BOOTSTRAP_REPO_NAME="terraform-gcp-bootstrap"
#MODULE_REPO_NAME="terraform-gcp-module"
#REPO_OWNER="kewei5zhang"

# Parse bootstrap config
MY_PATH="`dirname \"$0\"`"
read_config="sed -e 's/:[^:\/\/]/=\"/g;s/$/\"/g;s/ *=/=/g' $MY_PATH/bootstrap.yaml;"
env_var=$(eval "$read_config")
env_cli=$(echo $env_var | sed -e 's/^"//' -e 's/"$//')
eval "$env_cli"

# Validate bootstrap config
read -p "Is this your Build Project ID? ${BUILD_PROJECT_ID} [y/n]" yn
if [[ $yn = [Yy] ]]; then
	read -p "Is this your github Pipeline Bootstrap Repo Name? ${BOOTSTRAP_REPO_NAME} [y/n]" yn
else 
	echo "Bootstrap Abort!"
	exit 1
fi
if [[ $yn = [Yy] ]]; then
	read -p "Is this your github Terraform Module Repo Name? ${MODULE_REPO_NAME} [y/n]" yn
else 
	echo "Bootstrap Abort!"
	exit 1
fi
if [[ $yn = [Yy] ]]; then
	read -p "Is this your github Repo Owner ID? ${REPO_OWNER} [y/n]" yn
else
	echo "Bootstrap Abort!"
	exit 1
fi

# Configure GCP project
echo "Configure GCP Project - ${BUILD_PROJECT_ID}"
gcloud config set project ${BUILD_PROJECT_ID}

# Enable the required APIs
echo "Enable the required APIs"
gcloud services enable cloudresourcemanager.googleapis.com cloudbuild.googleapis.com compute.googleapis.com cloudkms.googleapis.com

# Configure Terraform backend
echo "Configure Terraform backend to Cloud Storage Bucket - ${BUILD_PROJECT_ID}-tfstate"
BUILD_PROJECT_ID=$(gcloud config get-value project)
BUCKET_STATUS=$(gsutil ls | grep ${BUILD_PROJECT_ID}-tfstate)
if [[ -z ${BUCKET_STATUS} ]]; then
	gsutil mb -p ${BUILD_PROJECT_ID} -c NEARLINE -l AUSTRALIA-SOUTHEAST1 -b on gs://${BUILD_PROJECT_ID}-tfstate
else
	echo "Bucket already exists"
fi
gsutil versioning set on gs://${BUILD_PROJECT_ID}-tfstate

# Granting permissions to Cloud Build SA
echo "Granting permissions to Cloud Build SA"
CLOUDBUILD_SA="$(gcloud projects describe ${BUILD_PROJECT_ID} \
		--format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding $BUILD_PROJECT_ID \
		--member serviceAccount:$CLOUDBUILD_SA --role roles/editor
gcloud projects add-iam-policy-binding $BUILD_PROJECT_ID \
		--member serviceAccount:$CLOUDBUILD_SA --role roles/secretmanager.secretAccessor

# Create Bootstrap Triggers
BOOTSTRAP_REPO_NAME=${BOOTSTRAP_REPO_NAME}
REPO_OWNER=${REPO_OWNER}
# Plan Trigger
BRANCH_PATTERN="feature/*"
DESCRIPTION="tf-bootstrap-plan"
BUILD_CONFIG="cloudbuild-plan.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${BOOTSTRAP_REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG}
else
	echo "${DESCRIPTION} trigger already exists"
fi
# Apply Trigger
BRANCH_PATTERN="^master$"
DESCRIPTION="tf-bootstrap-apply"
BUILD_CONFIG="cloudbuild-apply.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${BOOTSTRAP_REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG}
else
	echo "${DESCRIPTION} trigger already exists"
fi

# Create Module Triggers for Bootstrap Module
MODULE_REPO_NAME=${MODULE_REPO_NAME}
REPO_OWNER=${REPO_OWNER}
# Plan Trigger
MODULE="bootstrap-cloudbuild"
BRANCH_PATTERN="feature/${MODULE}*"
DESCRIPTION="tf-module-${MODULE}-dry-run"
BUILD_CONFIG="cloudbuild/cloudbuild-dry-run.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${MODULE_REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG} --substitutions=_MODULE=${MODULE} --included-files=modules/${MODULE}/**
else
	echo "${DESCRIPTION} trigger already exists"
fi

# Create Module Triggers for Bootstrap Module
MODULE_REPO_NAME=${MODULE_REPO_NAME}
REPO_OWNER=${REPO_OWNER}
# Plan Trigger
BRANCH_PATTERN="master"
DESCRIPTION="tf-module-git-tag-release"
BUILD_CONFIG="cloudbuild/cloudbuild-git-tag.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${MODULE_REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG}
else
	echo "${DESCRIPTION} trigger already exists"
fi


