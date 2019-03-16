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

function new_target() {
    if [ -d "./targets/$1" ]; then
        echo "Target $1 already exists"
        exit 1
    fi
    echo "creating $1"
    mkdir -p "targets/$1/"
    cp "targets/initial/dockerfile" "targets/$1/dockerfile"
    cp "targets/initial/initial.defconfig" "targets/$1/$1.defconfig"
    update-buildroot
    edit_target $1
}

new_target
