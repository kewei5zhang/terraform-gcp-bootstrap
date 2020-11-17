#!/bin/bash

set -exuo pipefail

cd env/${ENV}

# tflint --disable-rule=terraform_module_pinned_source
tflint