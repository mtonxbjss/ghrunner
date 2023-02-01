#!/usr/bin/env bash

set -uo pipefail;

color_cyan="$(git config --get-color "" "cyan bold")"
color_reset="$(git config --get-color "" "reset")"

echo -e "\n${color_cyan}Downloading latest image from github repository...${color_reset}\n"

read -p "Which release number do you want to cache in S3? " release_version
echo "${release_version:-0.0.0}"

latest_file_name="actions-runner-linux-x64-latest.tar.gz"

curl \
  -o ~/${latest_file_name} \
  -L https://github.com/actions/runner/releases/download/v${release_version:-0.0.0}/actions-runner-linux-x64-${release_version:-0.0.0}.tar.gz

if [[ ! -f ~/${latest_file_name} ]]; then
  echo -e "\n\n${color_cyan}Failed to obtain latest binary from github upstream repo!${color_reset}\n"
  exit 1;
fi

binary_size=$(du -k ~/${latest_file_name} | cut -f 1)
if [[ ${binary_size} -le 40000 ]]; then
  echo -e "\n\n${color_cyan}Downloaded github binary seems suspiciously small - upload anyway?${color_reset}\n"
  read confirmation
  if [[ ! "${confirmation^^}" =~ (Y|YES) ]]; then
    echo -e "\n\n${color_cyan}Aborted. Left the downloaded file behind at ~/${latest_file_name} so you can investigate ${color_reset}\n"
    exit 1;
  fi
fi

echo -e "\n\n${color_cyan}Uploading latest image to CaaS CICD S3 Bucket...${color_reset}\n"
aws s3 cp \
  ~/${latest_file_name} \
  s3://caas-pl-680509669821-eu-west-2-pl-mgmt-acct-cicd-artifacts/github-runner/${latest_file_name} \
  --acl bucket-owner-full-control

if [[ $? != 0 ]]; then
  echo -e "\n\n${color_cyan}Failed to upload latest binary to CICD bucket!${color_reset}\n"
  exit 1;
fi

rm ~/${latest_file_name}

echo -e "\n\n${color_cyan}Done!${color_reset}\n"
