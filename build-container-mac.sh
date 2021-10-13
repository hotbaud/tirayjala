#!/bin/bash
# This bash script builds a centos container image named <myprefix>/<containername>:<imgversion>
# using the mac docker environment and the input args.
#
# May require minor adjustments for Linux.  YMMV.
#
# Author:  Anne Marie Merritt
#          anne.marie.merritt@gmail.com
#
# Usage:
#     > ./build-container-mac.sh --imgversion 1.0 --containername tirayjala --prefixname epic
#
# Will output a compressed docker image in .tar.gz format suitable for loading into Docker.
#
#    Default: tirayjala-1.0.tar.gz
#
# Load the image into docker after its built:
#
#     > docker load -i tirayjala-1.0.tar.gz
#
# View via 
#     > docker images:
# ...
# epic/tirayjala   1.0    3e32955179d2     25 minutes ago     441MB
# ...
#
#
################################################################################
#
#
# This will reference the Dockerfile in this directory to build the image
# named as below.
#
# Usage:
#     > ./build-container.sh --imgversion 1.0 --containername tirayjala --prefixname epic
#
#
#set -x

set -a # export all the variable assignments in this file.

#define these for the case this script is called directly standalone
#THIS_SCRIPT=$( readlink -m $( type -p $0 ))
CURR_DIR="."

# Example default containername:  epic/tirayjala:1.0

DEFAULT_BUILDCONTAINER_NAME='tirayjala'
DEFAULT_BUILDCONTAINER_VERSION='1.0'
DEFAULT_PREFIX_NAME='epic'
IMGVERSION=''

print_help() {
    echo
    echo "USAGE: $0 [ -h ]"
    echo
    echo "            -h    : Prints usage details and exits."
    echo
    echo "     --imgversion : Base image version of MAJOR.MINOR format."
    echo "     --containername: name of container, e.g. 'mooby' or 'tirayjala'"
    echo "     --prefixname: name of prefix to container, e.g. 'epic' in 'epic/tirayjala '"
    echo "                   or dogma in dogma/mooby"
    echo
}

parse_options() {
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                print_help
                exit 0
                ;;
            --imgversion)
                IMGVERSION=$2
                shift
                ;;
            --containername)
                CONTAINERNAME=$2
                shift
                ;;
            --prefixname)
                PREFIXNAME=$2
                shift
                ;;
            --)
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    if [[ -z "${IMGVERSION}" ]]; then
        echo "NOTE:  --imgversion not specified. Using default version $DEFAULT_BUILDCONTAINER_VERSION instead."
        IMGVERSION=$DEFAULT_BUILDCONTAINER_VERSION
    fi
    if [[ -z "${CONTAINERNAME}" ]]; then
        echo "NOTE:  --containername not specified. Using default version $DEFAULT_BUILDCONTAINER_NAME instead."
        CONTAINERNAME=$DEFAULT_BUILDCONTAINER_NAME
    fi
    if [[ -z "${PREFIXNAME}" ]]; then
        echo "NOTE:  --prefixname not specified. Using default version $DEFAULT_PREFIX_NAME instead."
        PREFIXNAME=$DEFAULT_PREFIX_NAME
    fi
}

SHORTOPTS="h"
LONGOPTS="containername:,imgversion:,prefixname:,help"

# getopt from util-linux 2.34, via brew install
OPTS=$( /usr/local/opt/gnu-getopt/bin/getopt -u --options=$SHORTOPTS --longoptions=$LONGOPTS -- "$@")
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to parse the option(s) provided."
    print_help
    exit 1
fi

parse_options $OPTS

BUILDCONTAINER_BUNDLE_BASENAME="$CONTAINERNAME-$IMGVERSION.tar"
echo "NOTE: BUILDCONTAINER_BUNDLE_BASENAME is $BUILDCONTAINER_BUNDLE_BASENAME ."

BUILDCONTAINER_STRING="$PREFIXNAME/$CONTAINERNAME"
echo "NOTE: BUILDCONTAINER_STRING is $BUILDCONTAINER_STRING ."

build_docker_image() {
    echo "Building docker image:  docker build -t $1 ."
    docker build -t $1 .
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to build docker image: $1"
        exit 1
    fi
}

save_docker_image() {
    echo "Saving docker image : docker save -o ${BUILDCONTAINER_BUNDLE_BASENAME} $1"
    docker save -o ${BUILDCONTAINER_BUNDLE_BASENAME} $1
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to save docker image: ${BUILDCONTAINER_BUNDLE_BASENAME}"
        exit 1
    fi
    echo "Gzip'ing docker image : gzip -f9 ${BUILDCONTAINER_BUNDLE_BASENAME}"
    gzip -f9 ${BUILDCONTAINER_BUNDLE_BASENAME}
    echo "Image ${BUILDCONTAINER_BUNDLE_BASENAME}.gz successfully saved."
}

echo "Removing previous docker image with this version, if it exists."
docker rmi ${BUILDCONTAINER_STRING}:${IMGVERSION}
echo "Removing previously saved and gzip'd docker image, if it exists."
rm -rf ${BUILDCONTAINER_BUNDLE_BASENAME}.gz

echo "Building $BUILDCONTAINER_STRING image $BUILDCONTAINER_STRING:$IMGVERSION"
build_docker_image "${BUILDCONTAINER_STRING}:${IMGVERSION}"

echo "Saving $BUILDCONTAINER_STRING image $BUILDCONTAINER_STRING:$IMGVERSION"
save_docker_image "${BUILDCONTAINER_STRING}:${IMGVERSION}"
echo "Cleaning up docker to remove the image just built. Comment out to keep it."
docker rmi ${BUILDCONTAINER_STRING}:${IMGVERSION}

echo "Build complete! $BUILDCONTAINER_STRING image: ${BUILDCONTAINER_STRING}:${IMGVERSION} filename: ${BUILDCONTAINER_BUNDLE_BASENAME}.gz"

exit 0
