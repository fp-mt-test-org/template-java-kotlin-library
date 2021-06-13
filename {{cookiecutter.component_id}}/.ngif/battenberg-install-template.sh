#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

template_context_file='.cookiecutter.json'
template_context_path="./${template_context_file}"

# This codeblock answers the prompts issued by battenberg below.
{
    if [[ -d "$HOME/.cookiecutters" ]]; then
        # You've downloaded .../.cookiecutters/template-java-kotlin-library before.
        # Is it okay to delete and re-download it? [yes]:
        echo "1";
        sleep 1;
    fi

    # owner [Product Infrastructure]:
    jq '.owner' "${template_context_path}";
    sleep 1;

    # component_id []:
    jq '.component_id' "${template_context_path}"
    sleep 1;

    # repo_owner [fp-mt-test-org]:
    jq '.repo_owner' "${template_context_path}"
    sleep 1;

    # artifact_id [java-kotlin-lib-test-*****]:
    jq '.artifact_id' "${template_context_path}"
    sleep 1;

    # storePath [https://github.com/fp-mt-test-org/java-kotlin-lib-test-*****]:
    jq '.storePath' "${template_context_path}"
    sleep 1;

    # java_package_name [javakotlinlibtest*****]:
    jq '.java_package_name' "${template_context_path}"
    sleep 1;

    # description [*****]:
    jq '.description' "${template_context_path}"
    sleep 1;

    # destination [default]:
    jq -c '.destination' "${template_context_path}"
    sleep 1;
} | battenberg install "${github_base_url}/${template_name}"
