#!/bin/bash

# Script to run Ansible playbook in live or dry-run mode

# Variables
INVENTORY="inventory.ini"   # Path to your inventory file
MODE=${1}                   # First argument: live or dry
PLAYBOOK=${2}               # Path to your playbook
REPO_PATH="$(pwd)"      # Update with your repository root path

# Usage Instructions
usage() {
    echo "Usage: $0 {live|dry} {playbook_name}"
    echo "  live - Run the playbook in live mode (makes changes)"
    echo "  dry  - Run the playbook in dry-run mode (no changes)"
    exit 1
}

# Check input
if [[ -z "${MODE}" ]]; then
    echo "Error: Mode not specified."
    usage
fi

if [[ -z "${PLAYBOOK}" ]]; then
    echo "Error: Playbook not specified."
    usage
fi

# Ensure Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook command not found. Install Ansible first."
    exit 1
fi

echo "REPO ROOT PATH: ${REPO_PATH}"
pushd ${REPO_PATH}/ansible

## Check if the vault password is provided via an environment variable
#if [[ -z "$ANSIBLE_VAULT_PASSWORD" ]]; then
#    echo "Environment variable ANSIBLE_VAULT_PASSWORD is not set!"
#    exit 1
#fi
## Create a temporary file to store the vault password
#VAULT_PASSWORD_FILE=$(mktemp)
#echo "${ANSIBLE_VAULT_PASSWORD}" > "${VAULT_PASSWORD_FILE}"
#VAULT_ARGS="--vault-password-file=${VAULT_PASSWORD_FILE}"
VAULT_ARGS=""

# Run Ansible in live or dry-run mode
if [[ "$MODE" == "live" ]]; then
    echo "Running Ansible playbook in LIVE mode..."
    ansible-playbook -i "${INVENTORY}" "${PLAYBOOK}.yml" --extra-vars "repo_root=${REPO_PATH}" # ${VAULT_ARGS}
elif [[ "$MODE" == "dry" ]]; then
    echo "Running Ansible playbook in DRY-RUN mode..."
    ansible-playbook -i "${INVENTORY}" "${PLAYBOOK}.yml" --extra-vars "repo_root=${REPO_PATH}" --check --diff #${VAULT_ARGS}
else
    echo "Error: Invalid mode specified."
    usage
fi

popd
