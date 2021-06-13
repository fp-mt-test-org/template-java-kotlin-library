#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

echo "Determining if the template has been initialized..."
git_branches=$(git branch)

if ! [[ "${git_branches}" =~ "template" ]]; then
    echo "Template needs to be initialized, initializing..."
    ./.ngif/initialize-template.sh
else
    echo "Template has been previously initialized."
fi
