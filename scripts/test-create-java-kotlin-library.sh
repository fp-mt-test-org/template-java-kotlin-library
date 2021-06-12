#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# These tests are based on the steps outlined in the README.
# The purpose is to perform the same actions the README is asking
# people to do so we can catch any regressions with it.

i=0 # Step counter
owner_name='fp-mt-test-org'
github_base_url="https://github.com/${owner_name}"
template_name="template-java-kotlin-library"
flex='./flex.sh'

echo "=================================="
echo "TEST: Create library from template"
echo "=================================="
echo "Step $((i=i+1)): Generate Unique Project Name"
random_string=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 5 ; echo)
project_name="java-kotlin-lib-test-${random_string}"
echo "Project Name: ${project_name}"

get_actions_curl_command="curl -sH \"Accept: application/vnd.github.v3+json\" -H \"authorization: Bearer ${GITHUB_TOKEN}\" \"https://api.github.com/repos/fp-mt-test-org/${project_name}/actions/runs\""
echo
echo "Step $((i=i+1)): Submit Create Request to Maker Portal"
template_name="${template_name}" project_name="${project_name}" ./scripts/create-project.sh
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

echo "Step $((i=i+1)): Clone locally"
git clone "${github_base_url}/${project_name}.git"
cd "${project_name}"
echo
echo "Step $((i=i+1)): Setup dependencies"
"${flex}" setup-dependencies
echo
echo "Step $((i=i+1)): Initialize the template!"

battenberg_output=$( \
    github_base_url="${github_base_url}" \
    template_name="${template_name}" \
    project_name="${project_name}" \
    owner_name="${owner_name}" \
    ../scripts/initialize-template.sh 2>&1 || true \
)

# The "|| true" above is to prevent this script from failing
# in the event that initialize-template.sh fails due to errors,
# such as merge conflicts.

echo
echo "${battenberg_output}"
echo
echo "Checking for MergeConflictExceptions..."
echo
if [[ "${battenberg_output}" =~ "MergeConflictException" ]]; then
    echo "Merge Conflict Detected, attempting to resolve!"
    
    # Expecting 2 conflicts in .cookiecutter.json...

    # Remove all instances of:
    # <<<<<<< HEAD
    # ...
    # =======
    
    # And

    # Remove all instances of:
    # >>>>>>> 0000000000000000000000000000000000000000
    cookiecutter_json_updated=$(cat .cookiecutter.json | \
        perl -0pe 's/<<<<<<< HEAD[\s\S]+?=======//gms' | \
        perl -0pe 's/>>>>>>> [a-z0-9]{40}//gms')

    echo "${cookiecutter_json_updated}" > .cookiecutter.json
    echo
    echo "Conflicts resolved, committing..."
    git add .cookiecutter.json
    git commit -m "fix: Resolved merge conflicts with template."
else
    echo "No merge conflicts detected."
    exit 1
fi

echo
echo "Step $((i=i+1)): Verify Local Build is Successful"
"${flex}" build
echo

echo "Pushing template and master branches to remote..."
git push origin template
git push origin master
echo ""

echo "Attempting update-template..."
"${flex}" update-template

echo
echo "Passed!"
echo "Step $((i=i+1)): Cleanup"
cd ..
rm -fdr "${project_name}"
echo

echo "=================================="
echo "TEST: Update library from template"
echo "=================================="
i=0
expected_flex_version_initial='0.5.0'
expected_flex_version_upgrade='0.5.1'
repo_name='template-java-kotlin-library-test-template-update'

if [[ -d "${repo_name}" ]]; then
    rm -fdr "${repo_name}"
fi

echo "Step $((i=i+1)): Clone repo that was created from template"
git clone "${github_base_url}/${repo_name}.git"
cd "${repo_name}"
echo ""
echo "Step $((i=i+1)): Check current flex version"
"${flex}" -version
flex_version=$("${flex}" -version)
if [[ "${flex_version}" != "${expected_flex_version_initial}" ]]; then
    echo "ERROR: flex_version is ${flex_version} but expected ${expected_flex_version_initial}"
    exit 1
fi

echo ""
echo "Step $((i=i+1)): Update repo from updated template"
"${flex}" update-template
echo ""
echo "Step $((i=i+1)): Check the updated flex version"
"${flex}" -version
flex_version=$("${flex}" -version)
echo ""
if [[ "${flex_version}" != "${expected_flex_version_upgrade}" ]]; then
    echo "ERROR: flex_version is ${flex_version} but expected ${expected_flex_version_upgrade}"
    exit 1
fi
echo ""
echo "Step $((i=i+1)): Cleanup"
cd ..
rm -fdr "${repo_name}"
echo "Pass!"
