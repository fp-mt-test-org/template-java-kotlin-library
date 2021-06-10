## template-java-kotlin-library

This is a template for creating new Kotlin library projects.

## How to Use this Template

### How to create a new library

1. Go to backstage and select this template from the catalog to create a new library.
2. Set default branch from `master` to `main`.
3. Fork the repo
4. Clone the main library repo locally.
5. Configure your remotes

    `git remote set-url --push origin your-fork-url-here`

3. Setup dependencies

    `flex setup-dependencies`

4. Initialize the template

    `battenberg install https://github.com/fp-mt-test-org/template-java-kotlin-library`

5. Merge: Review & Accept All Incoming Changes
6. Commit
7. Push `template` and `main` branches

    `git push origin template`
    `git push origin main`

8. PR/Merge to main repo

### How to apply template updates

1. Apply the updates

    `flex update-template`

## How to Develop this Template

### Development Workflows

#### Pull
Sync your local with latest remote source:

    flex pull

#### Test
Test the templates in key scenarios such as creating and updating projects from templates.

    flex test

#### Push
Perform validation before pushing your changes to remote.

    flex push
