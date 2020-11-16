Pre-requisites
1. The Build project exists
2. The Environment Projects exist
3. CSR repos are created and synced with the provided terraform repos
4. Access to GCP (Onwer)
5. If using github as the connected cloudbuild repository - make sure cloudbuild is authenticated with the github repo and webhook got configured in github. Please visit https://console.cloud.google.com/cloud-build/triggers/connect?project=1014141585037 to connect a repository to your project
6. gcloud beta cli
7. No Cloud Build trigger created for other purposes with name TF-Bootstrap-Apply; TF-Bootstrap-Plan

Tech Debts:
1. Customized terraform image for build and analysis
