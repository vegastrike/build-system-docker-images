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
