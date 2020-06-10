#!/bin/bash

# fail fast
set -o errexit

terraform init
terraform plan
terraform apply