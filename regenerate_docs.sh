#!/usr/bin/env bash

set -euo pipefail

terraform-docs markdown table --output-file README.md imagebuilder-terraform-container
terraform-docs markdown table --output-file README.md imagebuilder-github-runner-ami
terraform-docs markdown table --output-file README.md autoscaling-github-runners

terraform fmt --recursive .
