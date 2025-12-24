FROM alpine:3.22
LABEL maintainer="Aleksei Kulik <a.kulik.it@gmail.com>"
EXPOSE 2049/tcp 2049/udp 111/tcp 111/udp 20048/tcp 20048/udp
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD rpcinfo -p localhost | grep -q nfs && \
        rpcinfo -p localhost | grep -q mountd && \
        rpcinfo -p localhost | grep -q portmapper || exit 1
VOLUME ["/exports"]

RUN apk add --no-cache nfs-utils && \
    mkdir -p /exports && \
    chmod 777 /exports && \
    echo "/exports *(rw,sync,no_subtree_check,no_auth_nlm,insecure,all_squash,anonuid=65534,anongid=65534,fsid=0)" > /etc/exports
WORKDIR /exports

ENTRYPOINT ["/bin/sh", "-c", "rpcbind && rpc.nfsd && exportfs -a && rpc.mountd -F"]
