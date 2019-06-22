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

## This function takes a target, applies it, builds it and then
## creates the docker image
## @fn build
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

build "${1}" "${2}"
