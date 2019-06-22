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

edit_target "${1}"
