# Image Tests

The functionality provided here allows one to test any of the Vega Strike Build Images
and perform an actual build of the source as we would do in CI.

The Dockerfile is parameterized to use the build image and then allow the caller
to set which fork and branch via `GIT_USER` and `GIT_BRANCH` respectively of the
VS code to build.

The user can then use `vs-image.sh` in order to build the image. This provided
as a convenience for how to use Build Args with Docker Images and to help
the caller know what to set.

Example:

    $ ./vs-image.sh --image-base "rockylinux_rockylinux_8.10" build
    ...
    $ ./vs-image.sh run
    [root@85fa1b0c4b92 Vega-Strike-Engine-Source]# 

The caller is dumped in as the root user so they can manipulate the image
runtime with package installation, removal, etc.

## Basic Usage

NOTE: The `vs-images.sh` script is presently setup to operate from within its home directory.

The `vs-images.sh` operates with a series of options and some commands to perform, the most basic of which is the
`help` command:

    $ ./vs-image.sh help
    ./vs-image.sh <options> <command>

      <options> may be one or more of the following:
          --docker           'docker' binary to use
          --github-user      Specify the github user or organization to use - Default: "vegastrike"
          --github-workflow  Specify the github workflow to use for images - Default: "../.github/workflows/gh-actions-pr.yml"
          --git-branch       Specify which Git Branch to use - Default: "master"
          --image-base       Specify which Vega Strike Image to use
          --image-tag        Specify tag name to use - Default: "vs_tester:latest"
          --yq               'yq' binary to use

      <command> may be one of the following:
          help             Show this dialog
          show-ci-images   Show image targets used by the CI systems
          show-images      List Images used by the Vega Strike CI system available locally
          build-base       Build the base image (CI Image)
          build            Build the image (Dev Image)
          run              Run the image


         Git Branch: "master"
    GitHub Username: "vegastrike"
    GitHub Workflow: "../.github/workflows/gh-actions-pr.yml"
         Image Base: ""
          Image Tag: "vs_tester:latest"

### Show CI Images

The `show-ci-images` command is used to analyze the GitHub Actions Workflow and output the images that would be generated.
These are used as the base images for the VS repositories and also the Dockerfile provided here.

This command is augmented by the `yq` command which is used to parse the GitHub Actions Workflows that are in YAML format.
As part of its operation it checks if the `yq` command specified is the one expected so that it knows the operation will
work properly. Unfortunately, different `yq` commands have different options. 

### Show Images

The `show-images` command is used to see what base images are available locally by examining the Docker Images cache.

### Build Base

The `build-base` command is used to build an image that would be used by the CI tooling.
It takes a single option (`--image-base`) to identify which CI Image to build.

### Build

The `build` command is used to build the testing Dockerfile that is loaded with the VS code. It uses most of the options to
provide its functionality.

### Run

The `run` command is used to start up the testing Dockefile to enable the user to test out the environment.
It simply needs the `--image-tag` option to identify the image to start and is a simple wrapper around the `docker run`
command to make it easy to access the Vega Strike Build Environments.

## Options

The script takes a number of different options. Many commands will output their view of the various options prior to the
command being run for easy diagnosis.

### --docker

The `--docker` option is used to specify the binary for the `docker` command and is used to list images, build images, and run images.

Default: `docker`

### --github-user

The `--github-user` option is used to specify the GitHub User or Organization from which to pull the Vega Strike Engine Source Code.

Default: `vegastrike`

### --github-workflow

The `--github-workflow` option is used to search for the possible Base Images to use. The value values are in this repositories `.github/workflows`
directory.

Default: `../.github/workflows/gh-actions-pr.yml`

### --git-branch

The `--git-branch` option is used to determine which branch in the repository to checkout.

Default: `master`

### --image-base

The `--image-base` option is used to specify which Vega Strike Docker Hub Docker Image to use as the base. However it pulls from the local system only.
This option contributes to the image name to be used in the format:

    vegastrike/vega-strike-build-env:<image base value>

Following the same design as the Vega Strike CI system.

### --image-tag

The `--image-tag` option is used to give the Dev Image a name for easy access. This should be a fully qualified name (name + tag) as opposed to just a name
in order to prevent mismatches since the `latest` tag would automatically be assumed.

### --yq

The `--yq` option is used to specify the YQ binary to be used for parsing the GitHub Workflow files.
This script is designed to use https://github.com/mikefarah/yq for YAML parsing.
