#!/bin/bash

set -exuo pipefail

cd env/${ENV}

tflint -f json
