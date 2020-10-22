#!/bin/bash
# set -x

# Parse bootstrap config
read_config="sed -e 's/:[^:\/\/]/=\"/g;s/$/\"/g;s/ *=/=/g' bootstrap.yaml;"
env_var=$(eval "$read_config")
env_cli=$(echo $env_var | sed -e 's/^"//' -e 's/"$//')
eval "$env_cli"

# Validate bootstrap config
read -p "Is this your Build Project ID? ${BUILD_PROJECT_ID} [y/n]" yn
if [[ $yn = [Yy] ]]; then
	read -p "Is this your github Repo Name? ${REPO_NAME} [y/n]" yn
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
gcloud services enable cloudbuild.googleapis.com compute.googleapis.com

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

# Create Bootstrap Triggers
REPO_NAME=${REPO_NAME}
REPO_OWNER=${REPO_OWNER}
# Plan Trigger
BRANCH_PATTERN="feature/*"
DESCRIPTION="TF-Bootstrap-Plan"
BUILD_CONFIG="cloudbuild-plan.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG}
else
	echo "${DESCRIPTION} trigger already exists"
fi
# Apply Trigger
BRANCH_PATTERN="^master$"
DESCRIPTION="TF-Bootstrap-Apply"
BUILD_CONFIG="cloudbuild-apply.yaml"
CLOUDBUILD_STATUS=$(gcloud beta builds triggers list --filter=name=${DESCRIPTION})
if [[ -z ${CLOUDBUILD_STATUS} ]]; then
	gcloud beta builds triggers create github --repo-name=${REPO_NAME} --repo-owner=${REPO_OWNER} --description=${DESCRIPTION} --branch-pattern=${BRANCH_PATTERN} --build-config=${BUILD_CONFIG}
else
	echo "${DESCRIPTION} trigger already exists"
fi




