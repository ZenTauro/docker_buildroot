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
    git submodule update --recursive --init

    # Links back the targets
    for filename in targets/*; do
        name=$(basename ${filename})
        if [ ! -f "./buildroot/configs/${name}_defconfig" ]; then
            ln -s "../../targets/${name}/${name}.defconfig" \
               "./buildroot/configs/${name}_defconfig"
        fi
    done
}

update_buildroot
