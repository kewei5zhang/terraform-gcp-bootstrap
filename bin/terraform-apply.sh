#!/bin/bash

set -exuo pipefail

echo "Running on $BRANCH_NAME branch"

terraform_apply () {
	bin/terraform-init.sh
	cd env/${ENV}
	terraform plan -out ${APP}-${ENV}.tfstate
	terraform apply -auto-approve ${APP}-${ENV}.tfstate
}

terraform_apply
