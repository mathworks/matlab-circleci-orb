## Contributing

To get started, install the CircleCI CLI:

```
brew install circleci
```

Familiarize yourself with the best practices in the [orb authoring process](https://circleci.com/docs/2.0/orb-author/).

Make changes to the orb in the src folder. After you are done updating, pack and validate the orb locally:

```
circleci orb pack src > orb.yml
circleci orb validate orb.yml
```
Note: the packed orb.yml file does not need to be committed to the repo. CircleCI will take care of all of this on release.

If you update the pipeline, you can try validating the config or locally executing jobs, but this behavior has been flaky with the dynamic configuration recommended in the orb authoring documentation.

```
circleci config validate
circleci local execute
```

## Creating a New Release

Changes should be made on a new branch. The new branch should be merged to the master branch via a pull request. Ensure that all of the CI pipeline checks and tests have passed for your changes. 

After the pull request has been approved and merged to master, follow the Github process for [creating a new release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository). This will kick off a new pipeline execution, and the orb will automatically be published to the CircleCI registry if the pipeline finishes successfully. Check the [Matlab orb registry](https://circleci.com/developer/orbs/orb/mathworks/matlab) for the new version after the pipeline finishes executing.
