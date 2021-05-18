#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

backstage_backend_base_url="${backstage_backend_base_url:=http://localhost:7000}"
template_name="${template_name:=template-java-kotlin-library}"
project_name="${project_name:=sample-project}"
github_base_url="${github_base_url:=https://github.com/fp-mt-test-org}"

create_project_json="{
    \"templateName\": \"${template_name}\",
    \"values\": {
        \"component_id\": \"${project_name}\",
        \"description\": \"This project was created from the ${template_name} template.\",
        \"owner\": \"Product Infrastructure\",
        \"storePath\": \"${github_base_url}/${project_name}\",
        \"access\": \"fp-mt\"
    }
}"

curl \
    -X POST -H "Content-Type: application/json" \
    -d "${create_project_json}" \
    "${backstage_backend_base_url}/api/scaffolder/v2/tasks"
