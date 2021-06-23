#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

brew install jfrog-cli

jfrog rt \
    gradle clean \
    artifactoryPublish -b build.gradle \
    --build-name={{cookiecutter.component_id}} \
    --build-number=1 \
    -Pversion=1.1.0-SNAPSHOT
