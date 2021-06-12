#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if [[ $CI ]]; then
    git config user.name "CI"
    git config user.email "ci@ci.com"
fi

battenberg_output=$(./battenberg-install-template.sh 2>&1 || true)

echo "${battenberg_output}"

cat .cookiecutter.json

# The "|| true" above is to prevent this script from failing
# in the event that initialize-template.sh fails due to errors,
# such as merge conflicts.

echo
echo "Checking for MergeConflictExceptions..."
echo
if [[ "${battenberg_output}" =~ "MergeConflictException" ]]; then
    template_context_file='.cookiecutter.json'
    echo "Merge Conflict Detected, attempting to resolve!"

    # Remove all instances of:
    # <<<<<<< HEAD
    # ...
    # =======
    
    # And

    # Remove all instances of:
    # >>>>>>> 0000000000000000000000000000000000000000
    
    cookiecutter_json_updated=$(cat ${template_context_file} | \
        perl -0pe 's/<<<<<<< HEAD[\s\S]+?=======//gms' | \
        perl -0pe 's/>>>>>>> [a-z0-9]{40}//gms')

    echo "${cookiecutter_json_updated}" > "${template_context_file}"
    echo
    cat .cookiecutter.json
    echo
    echo "Conflicts resolved, committing..."
    git add "${template_context_file}"
    git status
    git diff flex.sh
    git diff initialize-template.sh
    git commit -m "fix: Resolved merge conflicts with template."
else
    echo "No merge conflicts detected."
    exit 1
fi

echo
cat .cookiecutter.json
