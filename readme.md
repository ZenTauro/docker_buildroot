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
* `-n` Create a new target
* `-e` Edit a target
* `-u` Update buildroot and available targets
* `-r` Rebuild target
* `-l` List available targets and exit
* `-h` Print usage message
* `-v` Print version info and license info

Some targets are provided, but more can be created easily.

To create a new target named `nginx`, the following command can be used
`./build.sh -nt nginx`, if building the created target is not desired,
passing the `-l` (only list) flag can be passed `./build.sh -nlt nginx`.

By default it only derives from the defconfig and dockerfile used in the
`initial` target, which creates a container using glibc and compiled for
x86_64, in a close future this behavior will be changed to be able to 
use different configurations from the beginning.

If a previous target was built and the new one varies significantly from
the previous, it might be needed to rebuild the entire target. Such 
significant changes can be (but not limited to): 
- Processor type, eg x86 to arm
- C std library, eg musl to ulibc
- Compiler flags passed, eg `-Os` to `-O2`

As a good rule of thumb, every time the build process fails and you change
to a different target, pass the `-r` flag.

# Configuring targets
Adding packages is the most simple configuration to do, once you're in
the `menuconfig` screen, go to packages and select the ones that you
need, the dependencies will be selected accordingly.

In the **Target** screen, the target architecture is selected.

In the **Build** screen, the compiler flags and compilation related options
are selected.

In the **Toolchain** screen, the c std library, binutils, kernel headers,
gcc version and related options are selected.

In the **System Configuration** screen many options regarding the resulting
system are selected, some of them are:
- Host name
- Init system
- Locales
- fstab

and many more.

Since the resulting rootfs image is for a container, neither a kernel nor a
bootloader are needed.

In the **Filesystem** screen the format in which the rootfs image is saved,
is specified. The one used here is a tarball.
