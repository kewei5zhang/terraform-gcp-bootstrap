#!/bin/bash

set -exuo pipefail

sh bin/terraform-init.sh

cd env/${ENV}

terraform validate

tflint -f json
