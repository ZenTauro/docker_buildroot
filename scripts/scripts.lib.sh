#!/bin/bash

#    Helper script to make buildroot images
#    Copyright (C) 2018  zentauro
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

## @file
## @author ZenTauro <zentauro@riseup.net>
## @copyright GPLv3
## @version 0.1
## @brief Buildroot containers wrapper functions
## @details
## @par URL
## https://git.digitales.cslabrecha.org/zentauro/buildroot_starter @n
##
## @par Purpose
##
## This are the functions used to manage the targets in the buildroot
## containers wrapper
##
## @note
## This tool is still under development, it might suffer significant
## changes

## This function modifies a given target
## @fn edit_target()
## @brief Modify a target
## @param {target} $1 Target name
function edit_target() {
    (
        cd buildroot || return 1
        echo "applying target $1"
        make "${1}_defconfig" > /dev/null || return 2
        make menuconfig
        echo "saving defconfig, this might take a little while"
        make savedefconfig
    ) || return $?
}

## This function creates a target (by default from the initial target),
## applies it and then modifies it.
## @fn new_target()
## @brief Create new target
## @param {target} $1 Target name
## @param {from} $2 Base target to build upon
function new_target() {
    # Detect if the new target exits to prevent overwriting
    if [ -d "./targets/$1" ]; then
        return 1
    fi

    # Detect if a base target was provided
    if [ "${2}" != "" ]; then
        # Find whether the base target exists and return error
        # if it doesn't
        if [ -d "./targets/$2" ]; then
            base="./targets/$2"
        else
            return 2
        fi
    else
        # Default to the initial target
        base="./targets/initial"
    fi

    echo "creating $1"
    mkdir -p "targets/$1/"

    cp "${base}/dockerfile"         "targets/$1/dockerfile"
    cp "${base}/initial.defconfig"  "targets/$1/$1.defconfig"

    edit_target "$1" || return $?
}

## This function takes a target, applies it, builds it and then
## creates the docker image
## @fn build()
## @brief Create the docker container
## @param {target} $1 The target to build
## @param {rebuild_mode} $2 Whether it should rebuild or not
function build() {
    target=$1
    rebuild_mode=$2
    (
        cd buildroot                           || return
        # Apply the selected target config
        make "${target}_defconfig" > /dev/null || ( echo process failed && return 2 )
        printf "Building %s\n\n" "${target}"

        # Build the selected target with a build log
        if [ "${rebuild_mode}" == true ]; then
            make clean all | tee ./build.log
        else
            make | tee ./build.log
        fi
    ) || exit $? # Exit gracefully (not really lol)

    if [ ! -f ./rootfs.tar ]; then
        ln -s "./buildroot/output/images/rootfs.tar" .
    fi

    # Change the Dockerfile to the current target's one
    if [ -L ./Dockerfile ]; then
        rm Dockerfile
        ln -s "./targets/${target}/dockerfile" "./Dockerfile"
    fi

    # Show resulting tarball size
    echo resulting image is "$(du -sh ./buildroot/output/images/rootfs.tar)"

    # Build the container image
    docker build -f Dockerfile -t "${DOCKER_ID_USER}/${target}:latest" .
}


## This function cleans and updates the buildroot repo and updates the
## links to the targets
## @fn update_buildroot()
## @brief Update buildroot installation
function update_buildroot() {
    # it cleans up the configs directory
    if [ -d "./buildroot/scripts" ]; then
        rm -rf ./buildroot/configs
    fi

    # If the buildroot submodule is initialized, it cleans it
    # to prevent merging errors
    if [ -d "./buildroot/.git"  ]; then
        (
            cd buildroot || return 1
            git clean -f
            git reset --hard HEAD
        )
    fi

    # This updates it and then updates it
    git submodule update --recursive --init || return 2

    # Links back the targets
    for filename in targets/*; do
        name=$(basename "${filename}")
        if [ ! -f "./buildroot/configs/${name}_defconfig" ]; then
            ln -s "../../targets/${name}/${name}.defconfig" \
               "./buildroot/configs/${name}_defconfig"
        fi
    done
}
