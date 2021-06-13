#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

echo "Determining if the template has been initialized..."

git_branches=$(git branch)

if ! [[ "${git_branches}" =~ "template" ]]; then
    checkout_output=$(git checkout template 2>&1 || true)

    if [[ ${checkout_output} =~ "error: pathspec 'template' did not match any file(s) known to git" ]]; then
        echo "Template needs to be initialized, initializing..."
        ./.ngif/initialize-template.sh
    else
        git checkout master
    fi
else
    echo "Template has been previously initialized."
fi
