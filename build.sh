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
    if [ -d "./buildroot/scripts" ]; then
        rm -rf ./buildroot/configs
    fi
    if [ ! -d "./buildroot/.git"  ]; then
        (
            cd buildroot || return 1
            git clean -f
            git reset --hard HEAD
        )
        git submodule update --recursive --init
    fi

    for filename in defconfigs/*; do
        ln -s "../../$filename" ./buildroot/configs/
    done
}


if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then 
    echo Usage:
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

if [ "$1" == '-u' ]; then
    echo updating buildroot
    update-buildroot > /dev/null
else

    # show_gpl

    if [ ! -d "./buildroot/.git"  ]; then
        git submodule update --recursive --init
    fi
    for filename in defconfigs/*; do
        if [ ! -f "./buildroot/configs/${filename#defconfigs/}" ]; then
            echo "Linking \"${filename}\""
            ln -s "../../$filename" ./buildroot/configs/
        fi
    done
fi

counter=1
for filename in targets/*; do
    name=$(basename "${filename}")
    echo "${counter}.) ${name%_defconfig}"
    targets[counter]=${name}
    counter=$((counter+1))
done


echo -n "Choose a target to build: "
read target_num

target=${targets[target_num]}
if [ $target == '' ]; then
    echo no such target
    exit 1
fi
echo

(
    cd buildroot || return
    make "${target}" > /dev/null || ( echo process failed && return 1 )
    printf "Building ${target%_defconfig}\n\n"
    make | tee ./build.log
) || exit $?

if [ ! -f ./rootfs.tar ]; then
    ln -s "./buildroot/output/images/rootfs.tar" .
fi

echo resulting image is $(du -sh ./buildroot/output/images/rootfs.tar)

if [ ${DOCKER_ID_USER} == '' ]; then
    echo "DOCKER_ID_USER variable not set, please set it with your docker account name"
fi
docker build -f Dockerfile -t "${DOCKER_ID_USER}/${target}:latest" .
