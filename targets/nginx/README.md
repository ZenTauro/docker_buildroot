# NGINX Target

This target should be used as the base to construct nginx
containers, it doesn't contain the necessary certificates
by default, you need to include them using something like
the following:
``` Dockerfile
FROM alpine:latest as cert-img
RUN  apk --no-cache add ca-certificates

FROM zentauro/nginx
WORKDIR /etc/ssl/certs
COPY --from=cert-img /etc/ssl/certs/* ./
```
This is due to the fact that I cannot properly maintain
the certificates.

Since it is bare-bones image, it is necessary to include
the server certificates, entry point, ports, stop signal
and if you want the logs, a volume to store them.

``` Dockerfile
FROM zentauro/nginx

ENV NGINX_VERSION 1.13.5

# Include server certificates
VOLUME /etc/ssl
# A place for the logs
VOLUME /var/log/nginx

# Don't forget de config
COPY nginx.conf /etc/nginx/nginx.conf

# The ports where you want to listen
EXPOSE 80 443

# Stop signal
STOPSIGNAL SIGTERM

# And finally, the entry point
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
```

## NGINX modules
By default it doesn't include many modules, if you need
additional ones, you need to modify the defconfig by
running `./build.sh -et nginx`, going into `Target packages`
`--->` `Networking applications` `--->` `nginx` and then
select the needed modules. This will recompile nginx
with the specified settings.
