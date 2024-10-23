FROM alpine:latest

# Set non-interactive mode for installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache --update --verbose \
        nfs-utils \
        bash \
<<<<<<< Updated upstream
        iproute2 && \
        rm -rf /var/cache/apk /tmp /sbin/halt /sbin/poweroff /sbin/reboot && \
=======
        s3fs-fuse \
        iproute2 && \
        rm -rf /var/cache/apk /sbin/halt /sbin/poweroff /sbin/reboot && \
>>>>>>> Stashed changes
        mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
        echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
        echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY exports /etc/

EXPOSE 2049

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
