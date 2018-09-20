FROM scratch
ADD  rootfs.tar /
CMD  ["/usr/sbin/nginx"]
