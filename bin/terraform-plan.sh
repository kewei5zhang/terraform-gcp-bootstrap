#!/bin/bash

set -exuo pipefail

sh bin/terraform-init.sh

cd env/${ENV}

terraform plan -out ${APP}-${ENV}.tfstate 
