# 2.0.0 Wishlist
- Move targets to other repos and treat them like packages
- Migrate to python
- Update readme

## Package structure
At the top level there must be three files:
```
.
├── dockerfile
├── manifest.json
├── LICENSE
├──
└── target-name.defconfig
```

* **`dockerfile`**: It is the Dockerfile with the instructions to build the image, it must inherit `FROM scratch` and have an `ADD rootfs.tar /` instruction.
* **`target-name.defconfig`**: The defconfig generated with buildroot.
* **`manifest.json`**: This is the file where the package metadata goes, it must contain the following fields (the ones with ? are optional):
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
