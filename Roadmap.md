# 1.0.0 Wishlist
- Move targets to other repos and treat them like packages
- Migrate to rust
- Update readme

# New project structure
Bundle a compiled version of the program with the default
workspace layout and without the sources in the releases tab.

Motivations to move to this proposed layout:
- While bash is universally available and other scripting
  languages like python and js can get the work done they
  present some drawbacks.
  - **Python:** I personally do not like the syntax and the
  dependency management with pip is somewhat cumbersome in
  the sense that it defaults to globally install packages or
  you need to create a virtualenv.
  - **JavaScript:** Dependency management with npm is really
  nice, however the resulting `node_modules` tends to weight
  more than the entire universe with just one dependency and
  unless you develop js, node is not that common. Also, working
  with webpack, parcel, etc. is a pain.
  - **Bash:** Since the we mainly interact with terminal
  commands, bash is a great fit for this application. However,
  there is no dependency management tool and for creating CLI
  applications it stops being ergonomic.
  - **Rust:** It is the language I'm more comfortable on. It
  provides interfaces to work with git repositories and creating
  CLIs with autocompletion. Moreover, it produces a binary that
  only depends on libc.

For the tool to be extensible, it needs to support some kind of
packages. Since the only possible nested dependencies will be
managed by either Docker or buildroot, the `package.json` will
only take care of simple metadata.

Json format was chosen because it provides a simple to understand
syntax and it is very popular.

## Package structure
At the top level there must be at least the following three files
(please note that caps matter and the names must be exactly the
ones described here):
```
.
├── Dockerfile
├── manifest.json
├── LICENSE
:
└── ${target-name}.defconfig
```

- **`dockerfile`**: It is the Dockerfile with the instructions to build
  the image, it must inherit `FROM scratch` and have an `ADD rootfs.tar /`
  instruction.
- **`target-name.defconfig`**: The defconfig generated with buildroot.
- **`manifest.json`**: This is the file where the package metadata goes,
  it must contain the following fields (the ones with ? are optional):
```json
{
    "package": {
        "name": "${target-name}",
        "version": "0.0.0",
        "authors": [{
            "name": "author1-name",
            "info"?: "mail, webpage, or similar"
        },
        {
            "name": "author2-name",
            "info"?: "mail, webpage, or similar"

        }],
        "license": "license-name",
        "image"?: "./relative/path.[jpeg|png]"
    }
}
```
There can be any other files needed to build the target. Nonetheless,
the directory should be kept as minimal as possible.
