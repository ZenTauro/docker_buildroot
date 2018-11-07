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

function show_gpl() {
    echo \
'Copyright (C) 2018  zentauro
This program comes with ABSOLUTELY NO WARRANTY; for details type ./build.sh -h .
This is free software, and you are welcome to redistribute it
under certain conditions; type cat "LICENSE.md" for details.'
}

function update-buildroot() {
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
    git submodule update --recursive --init

    # Links back the targets
    for filename in targets/*; do
        name=$(basename ${filename})
        if [ ! -f "./buildroot/configs/${name}_defconfig" ]; then
            ln -s "../../targets/${name}/${name}.defconfig" "./buildroot/configs/${name}_defconfig"
        fi
    done
}


if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
    echo 'Usage:'
    echo 'interactive mode $ ./build.sh'
    echo 'update buildroot and targets $ ./build.sh -u'
    echo 'help $ ./build.sh -h'
    echo 'version info and license $ ./build.sh -v'
    exit
fi

if [ "$1" == -v ]; then
    echo version 1
    exit
fi

# Detect update flag
if [ "$1" == '-u' ]; then
    echo updating buildroot
    update-buildroot #> /dev/null
else
    if [ ! -d "./buildroot/.git"  ]; then
        git submodule update --recursive --init
    fi
    # Detect whether all the targets are present
    # if not, add them
    for filename in targets/*; do
        name=$(basename ${filename})
        if [ ! -f "./buildroot/configs/${name}_defconfig" ]; then
            echo "Linking \"${name}\""
            ln -s "../../targets/${name}/${name}.defconfig" "./buildroot/configs/${name}_defconfig"
        fi
    done
fi

counter=1
# List all targets by their basename and count them
for filename in targets/*; do
    name=$(basename "${filename}")
    echo "${counter}.) ${name}"
    targets[counter]=${name}
    counter=$((counter+1))
done


# Select the target
echo -n "Choose a target to build: "
read target_num

# Detect whether the target exists
# TODO do it better
target=${targets[target_num]}
if [ $target == '' ]; then
    echo no such target
    exit 1
fi
echo

(
    cd buildroot                 || return
    # Apply the selected target config
    make "${target}" > /dev/null || ( echo process failed && return 1 )
    printf "Building ${target}\n\n"
    # Build the selected target with a build log
    make | tee ./build.log
) || exit $? # Exit gracefully (not really lol)

if [ ! -f ./rootfs.tar ]; then
    ln -s "./buildroot/output/images/rootfs.tar" .
fi

# Change the Dockerfile to the current target's one
if [ -f ./Dockerfile ]; then
    rm Dockerfile
    ln -s "./targets/${target}/dockerfile" "./Dockerfile"
fi

# Show resulting tarball size
echo resulting image is $(du -sh ./buildroot/output/images/rootfs.tar)

# For taging the image, detect if the Docker id
# var is set
if [ "$DOCKER_ID_USER" == '' ]; then
    echo "DOCKER_ID_USER variable not set, please set it with your docker account name"
fi

# Build the container image
docker build -f Dockerfile -t "${DOCKER_ID_USER}/${target}:latest" .
