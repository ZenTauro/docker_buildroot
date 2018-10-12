FROM scratch
ADD  rootfs.tar /
ENTRYPOINT ["/usr/sbin/nginx"]
