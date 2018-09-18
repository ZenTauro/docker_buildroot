#!/bin/bash

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

if [ "$1" == '-u' ]; then
    echo updating buildroot
    update-buildroot > /dev/null
else
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
for filename in defconfigs/*; do
    name=$(basename "${filename}")
    echo "${counter}.) ${name%_defconfig}"
    targets[counter]=${name}
    counter=$((counter+1))
done


echo -n "Choose a target to build: "
read target_num

target=${targets[target_num]}
echo

(
    cd buildroot || return
    make "${target}"
)