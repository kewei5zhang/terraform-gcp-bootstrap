#!/bin/bash

set -exuo pipefail

bin/terraform-init.sh

cd env/${ENV}

terraform validate

tflint -f json
