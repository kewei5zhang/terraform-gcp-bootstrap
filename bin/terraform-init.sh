#!/bin/bash

set -exuo pipefail

cd env/${ENV}

terraform get -update

terraform init \
	-backend-config="bucket=${PROJECT_ID}-tfstate" \
	-backend-config="prefix=${APP}-${ENV}" \
	-reconfigure \
	-get=false \
	# -get-plugins=false \
	# -plugin-dir=/terraform.d/plugins
