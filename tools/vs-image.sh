#!/bin/bash

# Options
DOCKER=docker
GITHUB_USERNAME="vegastrike"
GITHUB_WORKFLOW="../.github/workflows/gh-actions-pr.yml"
GIT_BRANCH="master"
IMAGE_BASE=""
IMAGE_TAG="vs_tester:latest"
YQ=yq

# Error message accumulator
MY_ERRORS=""

# Print out the error messages for the user
function printErrors() {
    printf "${MY_ERRORS}"
}

# Add an error message to the error message accumulator
function recordErrorString() {
    local NEW_ERROR="${1}"
    if [ -n "${NEW_ERROR}" ]; then
        MY_ERRORS="${NEW_ERROR}\n${MY_ERRORS}"
    fi
}

# Determine if the error string needs to be output before
# terminating the program using the return code from the previous command
# return the code so it can then be used to exit the application
function processOpErrors() {
    local -i result=${1}
    if [ ${result} -ne 0 ]; then
        printErrors
    fi
    return ${result}
}

# Check if `yq` is installed and if so is it the one expected?
# There are different implementations and they do not act the same way.
# So this is setup to use one that will easily parse and output the results
function isYqInstalled() {
    local YQ_VERSION_DATA=$(${YQ} --version)
    local -i result=0
    if [ $? -ne 0 ]; then
        recordErrorString "YQ by https://github.com/mikefarah/yq is not installed"
        let -i result=1
    else
        local YQ_REPO=$(echo "${YQ_VERSION_DATA}" | cut -f 2 -d '(' | cut -f 1 -d ')')
        if [ "${YQ_REPO}" != "https://github.com/mikefarah/yq/" ]; then
            recordErrorString "YQ Version: ${YQ_VERSION_DATA}"
            recordErrorString "Unexpected YQ version installed. Please use the version by https://github.com/mikefarah/yq"
            let -i result=2
        fi
    fi

    return ${result}
}

# Command: CMD_SHOW_RELEASE_IMAGES
function printImageReleaseNames() {
    isYqInstalled
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "The following images targets are available:"
    IFS="
"
    for IMAGE_NAME in $(${YQ} eval '.jobs.build.strategy.matrix.FROM*' ${GITHUB_WORKFLOW}  | grep -v ^# | cut -f 2 -d \' | sort)
    do
        printf "\t${IMAGE_NAME}\n"
    done
    return 0
}

# Command: CMD_SHOW_IMAGES
function printImageLocalNames() {
    isYqInstalled
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "The following images are available locally:"
    IFS="
"
    for IMAGE_NAME in $(docker images | grep ^vegastrike | tr -s ' ' ';' | cut -f 2 -d ';' | sort)
    do
        printf "\t${IMAGE_NAME}\n"
    done
    return 0
}

# Command: CMD_BUILD_BASE_IMAGE
function buildBaseImage() {
    local IMAGE_BASE="${1}"
    local DOCKER_IMG_NAME="vegastrike/vega-strike-build-env:$(echo "${IMAGE_BASE}" | sed 's/:/_/' | sed 's/\//_/')"
    local IS_RELEASE=0
    local MY_OS_NAME="linux"
    ${DOCKER} build \
        --build-arg from="${IMAGE_BASE}" \
        --tag "${DOCKER_IMG_NAME}" \
        ..
}

# Command: CMD_BUILD_IMAGE
function buildImage() {
    local IMAGE_BASE="${1}"
    local IMAGE_TAG="${2}"
    local GIT_USER="${3}"
    local GIT_BRANCH="${4}"
    ${DOCKER} build \
        --build-arg CI_OS_IMAGE="${IMAGE_BASE}" \
        --build-arg GIT_USER="${GIT_USER}" \
        --build-arg GIT_BRANCH="${GIT_BRANCH}" \
        --tag ${IMAGE_TAG} \
        .
}

# Command: CMD_RUN_IMAGE
function runImage() {
    local IMAGE_TAG="${1}"
    ${DOCKER} run -it "${IMAGE_TAG}" /bin/bash
}

# output option values for debugging
function printInfo() {
    echo
    echo "     Git Branch: \"${GIT_BRANCH}\""
    echo "GitHub Username: \"${GITHUB_USERNAME}\""
    echo "GitHub Workflow: \"${GITHUB_WORKFLOW}\""
    echo "     Image Base: \"${IMAGE_BASE}\""
    echo "      Image Tag: \"${IMAGE_TAG}\""
    echo
}

# Variablized commands and argument names
CMD_HELP="help"
CMD_SHOW_RELEASE_IMAGES="show-ci-images"
CMD_SHOW_IMAGES="show-images"
CMD_BUILD_BASE_IMAGE="build-base"
CMD_BUILD_IMAGE="build"
CMD_RUN_IMAGE="run"

ARG_IMAGE_BASE="--image-base"
ARG_IMAGE_TAG="--image-tag"
ARG_GITHUB_USERNAME="--github-user"
ARG_GITHUB_WORKFLOW="--github-workflow"
ARG_GIT_BRANCH="--git-branch"
ARG_YQ="--yq"
ARG_DOCKER="--docker"

# Command: CMD_HELP
function printHelp() {
    local SCRIPT_NAME="${1}"
    echo "${SCRIPT_NAME} <options> <command>"
    echo
    echo "  <options> may be one or more of the following:"
    echo "      ${ARG_DOCKER}           'docker' binary to use"
    echo "      ${ARG_GITHUB_USERNAME}      Specify the github user or organization to use - Default: \"${GITHUB_USERNAME}\""
    echo "      ${ARG_GITHUB_WORKFLOW}  Specify the github workflow to use for images - Default: \"${GITHUB_WORKFLOW}\""
    echo "      ${ARG_GIT_BRANCH}       Specify which Git Branch to use - Default: \"${GIT_BRANCH}\""
    echo "      ${ARG_IMAGE_BASE}       Specify which Vega Strike Image to use"
    echo "      ${ARG_IMAGE_TAG}        Specify tag name to use - Default: \"${IMAGE_TAG}\""
    echo "      ${ARG_YQ}               'yq' binary to use"
    echo
    echo "  <command> may be one of the following:"
    echo "      ${CMD_HELP}             Show this dialog"
    echo "      ${CMD_SHOW_RELEASE_IMAGES}   Show image targets used by the CI systems"
    echo "      ${CMD_SHOW_IMAGES}      List Images used by the Vega Strike CI system available locally"
    echo "      ${CMD_BUILD_BASE_IMAGE}       Build the base image (CI Image)"
    echo "      ${CMD_BUILD_IMAGE}            Build the image (Dev Image)"
    echo "      ${CMD_RUN_IMAGE}              Run the image"
    echo
}

# Script argument processing
ARG_NAME=""
for ARG in $@
do
    # if ARG_NAME is not set then treat it as a command or argument name
    # arguments will set ARG_NAME to fall to the `else` condition to save
    # the value, then reset ARG_NAME once it has all is parts.
    if [ -z "${ARG_NAME}" ]; then
        case "${ARG}" in
            "${CMD_HELP}")
                printHelp "${0}"
                printInfo
                exit 0
                ;;
            "${CMD_SHOW_RELEASE_IMAGES}")
                printImageReleaseNames "${YQ}"
                processOpErrors $?
                exit $?
                ;;
            "${CMD_SHOW_IMAGES}")
                printImageLocalNames "${YQ}"
                processOpErrors $?
                exit $?
                ;;
            "${CMD_BUILD_BASE_IMAGE}")
                printInfo
                buildBaseImage "${IMAGE_BASE}"
                processOpErrors $?
                exit $?
                ;;
            "${CMD_BUILD_IMAGE}")
                printInfo
                buildImage "${IMAGE_BASE}" "${IMAGE_TAG}" "${GITHUB_USERNAME}" "${GIT_BRANCH}"
                processOpErrors $?
                exit $?
                ;;
            "${CMD_RUN_IMAGE}")
                printInfo
                runImage "${IMAGE_TAG}"
                processOpErrors $?
                exit $?
                ;;
            "${ARG_IMAGE_BASE}"|"${ARG_IMAGE_TAG}"|"${ARG_GITHUB_USERNAME}"|"${ARG_GIT_BRANCH}"|"${ARG_YQ}"|"${ARG_GITHUB_WORKFLOW}"|"${ARG_DOCKER}")
                # All arguments can be easily checked as one group
                ARG_NAME="${ARG}"
                ;;
            *)
                echo "Unknown command or option: ${ARG}"
                ;;
        esac
    else
        case "${ARG_NAME}" in
            "${ARG_IMAGE_BASE}")
                IMAGE_BASE="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_IMAGE_TAG}")
                IMAGE_TAG="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_GITHUB_USERNAME}")
                GITHUB_USERNAME="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_GITHUB_WORKFLOW}")
                GITHUB_WORKFLOW="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_GIT_BRANCH}")
                GIT_BRANCH="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_YQ}")
                YQ="${ARG}"
                ARG_NAME=""
                ;;
            "${ARG_DOCKER}")
                DOCKER="${ARG}"
                ARG_NAME=""
                ;;
            *)
                echo "Unknown option name: ${ARG_NAME}"
                ARG_NAME=""
                ;;
        esac
    fi
done

