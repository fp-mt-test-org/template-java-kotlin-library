#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

i=0 # Step counter

echo "Step $((i=i+1)): Generate Unique Project Name"
random_string=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 5 ; echo)
project_name="java-kotlin-lib-test-${random_string}"
echo "Project Name: ${project_name}"

get_actions_curl_command="curl -sH \"Accept: application/vnd.github.v3+json\" -H \"authorization: Bearer ${GITHUB_TOKEN}\" \"https://api.github.com/repos/fp-mt-test-org/${project_name}/actions/runs\""
echo
echo "Step $((i=i+1)): Submit Create Request to Maker Portal"
template_name="template-java-kotlin-library" project_name="${project_name}" ./create-project.sh
echo 
echo
echo "Step $((i=i+1)): Wait for GitHub Repo to be Created"
counter=0
max_tries=10
seconds_between_tries=3
while true; do
    echo "${counter} Checking..."
    response=$(eval "${get_actions_curl_command}")

    if [[ "${response}" =~ "Not Found" ]]; then
        echo "${project_name} not yet found."
    else
        echo "Repo found!"
        break
    fi

    if [[ "${max_tries}" == "${counter}" ]]; then
        echo "Giving up after ${max_tries}, test failed!"
        exit 1
    fi

    counter=$((counter+1))
    sleep "${seconds_between_tries}"
done
echo 
echo "Step $((i=i+1)): Verify CI Build is Successful"
counter=0
max_tries=100
seconds_between_tries=3
while true; do
    echo "${counter} Checking for build result..."
    response=$(eval "$get_actions_curl_command")

    if [[ "${response}" =~ \"status\"\:[[:space:]]+\"([A-Za-z_]+)\" ]]; then
        status="${BASH_REMATCH[1]}"
        echo "status: ${status}"
    else
        status="unknown"
    fi

    if [[ "${response}" =~ \"conclusion\"\:[[:space:]]+\"*([A-Za-z_]+)\"* ]]; then
        conclusion="${BASH_REMATCH[1]}"
        echo "conclusion: ${conclusion}"
    else
        conclusion="unknown"
    fi

    if [[ "${status}" == "completed" ]]; then
        if [[ "${conclusion}" != "success" ]]; then
            echo "Build was not successful, test failed!"
            exit 1
        else
            break
        fi
    fi

    if [[ "${max_tries}" == "${counter}" ]]; then
        echo "Giving up after ${max_tries}, test failed!"
        exit 1
    fi

    counter=$((counter+1))
    sleep "${seconds_between_tries}"

    echo
done
echo
echo "Step $((i=i+1)): Verify Local Build is Successful"
git clone "https://github.com/fp-mt-test-org/${project_name}.git"
cd "${project_name}"
./install-dev-dependencies.sh
./.devx-workflows/flex build
echo
echo "Passed!"
cd ..
rm -fdr "${project_name}"
