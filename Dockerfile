FROM scratch
ADD  rootfs.tar /
ADD  https://nightly.odoo.com/9.0/nightly/src/odoo_9.0.latest.tar.gz
ENTRYPOINT ["/usr/bin/python"]
