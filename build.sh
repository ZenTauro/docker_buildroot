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
This program comes with ABSOLUTELY NO WARRANTY; for details type ./build.sh -h
This is free software, and you are welcome to redistribute it
under certain conditions;

Type cat "LICENSE.md" for details.'
}

function usage() {
    echo 'Usage:'
    printf "\t%s [-u] [-r] [-v] [-h] [-n] [-t TARGET_NAME]\n" "${0}"
    echo
    printf "If no target is provided, it will run iteractively\n"
    printf '\t-t TARGET_NAME build the given TARGET_NAME\n'
    printf '\t-n Create a new target\n'
    printf '\t-e Edit a target target\n'
    printf '\t-u Update buildroot and available targets\n'
    printf '\t-r Rebuild target\n'
    printf '\t-l List available targets and exit\n'
    printf '\t-h Print this usage message\n'
    printf '\t-v Print version info and license info\n'
    exit
}

# For taging the image, detect if the Docker id
# var is set
if [ "${DOCKER_ID_USER}" == '' ]; then
    echo "DOCKER_ID_USER variable not set, please set it with your docker account name"
    exit
fi

# Unset the target var, just in case
unset target
unset rebuild_mode
unset new_name
# Parse the flags passed
while getopts "enlurvht:" o; do
    case "${o}" in
        u)
            echo updating buildroot
            update-buildroot ;;
        r)
            echo rebuild mode set
            rebuild_mode=true ;;
        l)
            onlylist=true ;;
        v)
            echo version 1
            echo
            show_gpl
            exit ;;
        h)
            usage
            exit ;;
        t)
            target=${OPTARG} ;;
        n)
            new_name="some" ;;
        e)
            edittarget="true" ;;
        *)
            echo "Invalid flag"
            exit ;;
    esac
done

if [ "${new_name}" == some ]; then
    if [ "${target}" == '' ]; then
        echo -n "Enter a new name: "
        read target
    fi
    new_target ${target} || exit
fi

if [ ! -d "./buildroot/.git"  ]; then
    git submodule update --recursive --init
fi
# Detect whether all the targets are present
# if not, add them
for filename in targets/*; do
    name=$(basename ${filename})
    if [ ! -f "./buildroot/configs/${name}_defconfig" ]; then
        echo "Linking \"${name}\""
        ln -s "../../targets/${name}/${name}.defconfig" \
              "./buildroot/configs/${name}_defconfig"
    fi
done

unset istarget
istarget=false
unset counter
counter=1
# List all targets by their basename and count them,
# if non interactive, also check if the target exists
for filename in targets/*; do
    name=$(basename "${filename}")
    if [ ! ${target} ]; then
        echo "${counter}.) ${name}"
    fi
    targets[counter]=${name}
    if [ "${target}" == "${name}" ]; then
        istarget=true
    fi
    counter=$((counter+1))
done

if [ "${edittarget}" == "true" ]; then
    if [ "${target}" == '' ]; then
        echo -n "Enter target: "
        read target_num
        target=${targets[target_num]}
        if [ "${target}" == '' ]; then
            echo no such target
            exit 2
        fi
    fi
    edit_target ${target} || exit
fi

if [ "${onlylist}" == true ]; then
    exit
fi

# If no target provided, run interactive
if [ ! ${target} ]; then
    # Select the target
    echo -n "Choose a target to build: "
    read target_num
    target=${targets[target_num]}
    istarget=true
    echo "${target} selected"
fi

# Detect whether the target exists
if [[ "${target}" == '' || "${istarget}" == false ]]; then
    echo "no such target"
    exit 1
fi

echo

(
    cd buildroot                           || return
    # Apply the selected target config
    make "${target}_defconfig" > /dev/null || ( echo process failed && return 1 )
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
echo resulting image is $(du -sh ./buildroot/output/images/rootfs.tar)


# Build the container image
docker build -f Dockerfile -t "${DOCKER_ID_USER}/${target}:latest" .
