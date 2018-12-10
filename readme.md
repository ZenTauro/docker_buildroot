What is this?
================
A simple framework to create minimal docker images with buildroot.

# Dependencies
You need to have installed make, git and gcc.
Also, for the `make menuconfig`, you will need libncurses.

# Usage

```sh
# Clone the repository 
git clone https://git.digitales.cslabrecha.org/zentauro/buildroot_starter.git
# Execute the script
./build.sh
```

It can be used interactively or by passing arguments.
If no target is provided, it will run iteractively.

* `-t TARGET_NAME` build the given TARGET_NAME
* `-u` Update buildroot and available targets
* `-r` Rebuild target
* `-l` List available targets and exit
* `-h` Print usage message
* `-v` Print version info and license info

Some targets are provided, but more can be created easely,
