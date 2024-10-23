#!/bin/bash

<<<<<<< Updated upstream
# Make sure we react to these signals by running stop() when we see them - for clean shutdown
# And then exiting
trap "stop; exit 0;" SIGTERM SIGINT

stop() {
    # We're here because we've seen SIGTERM, likely via a Docker stop command or similar
    # Let's shutdown cleanly
    echo "SIGTERM caught, terminating NFS process(es)..."
=======
trap "stop; exit 0;" SIGTERM SIGINT

S3FS_PASSWD_FILE=/tmp/passwd-s3fs
ENABLE_CACHE=${ENABLE_CACHE:-0}

stop() {
>>>>>>> Stashed changes
    /usr/sbin/exportfs -uav
    /usr/sbin/rpc.nfsd 0
    pid1=$(pidof rpc.nfsd)
    pid2=$(pidof rpc.mountd)
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
    # For IPv6 bug:
    pid3=$(pidof rpcbind)
    kill -TERM $pid1 $pid2 $pid3 >/dev/null 2>&1
    echo "Terminated."
    exit
}

<<<<<<< Updated upstream
rm /etc/exports

# Check if the SHARED_DIRECTORY variable is empty
=======
function set_s3_access {
    echo "$1:$2" >$S3FS_PASSWD_FILE
    chmod 600 $S3FS_PASSWD_FILE
}

function mount_s3_bucket {
    echo "Mounting s3 bucket '$2' from '$1' to $SHARED_DIRECTORY"
    OPTIONS="passwd_file=$S3FS_PASSWD_FILE,umask=022,allow_other,url=$1"
    if [ $ENABLE_CACHE -ne 0 ]; then
        OPTIONS="$OPTIONS,use_cache=/tmp"
    fi
    s3fs -d -o "$OPTIONS" $2 $SHARED_DIRECTORY
}

rm /etc/exports

>>>>>>> Stashed changes
if [ -z "${SHARED_DIRECTORY}" ]; then
    echo "The SHARED_DIRECTORY environment variable is unset or null, exiting..."
    exit 1
else
    echo "Writing SHARED_DIRECTORY to /etc/exports file"
    echo "{{SHARED_DIRECTORY}} {{PERMITTED}}({{READ_ONLY}},fsid=0,{{SYNC}},no_subtree_check,no_auth_nlm,insecure,no_root_squash)" >>/etc/exports
    /bin/sed -i "s@{{SHARED_DIRECTORY}}@${SHARED_DIRECTORY}@g" /etc/exports
fi

<<<<<<< Updated upstream
# Check if the PERMITTED variable is empty
=======
>>>>>>> Stashed changes
if [ -z "${PERMITTED}" ]; then
    echo "The PERMITTED environment variable is unset or null, defaulting to '*'."
    echo "This means any client can mount."
    /bin/sed -i "s/{{PERMITTED}}/*/g" /etc/exports
else
    echo "The PERMITTED environment variable is set."
    echo "The permitted clients are: ${PERMITTED}."
    /bin/sed -i "s/{{PERMITTED}}/"${PERMITTED}"/g" /etc/exports
fi

# Check if the READ_ONLY variable is set (rather than a null string) using parameter expansion
if [ -z ${READ_ONLY+y} ]; then
    echo "The READ_ONLY environment variable is unset or null, defaulting to 'rw'."
    echo "Clients have read/write access."
    /bin/sed -i "s/{{READ_ONLY}}/rw/g" /etc/exports
else
    echo "The READ_ONLY environment variable is set."
    echo "Clients will have read-only access."
    /bin/sed -i "s/{{READ_ONLY}}/ro/g" /etc/exports
fi

# Check if the SYNC variable is set (rather than a null string) using parameter expansion
if [ -z "${SYNC+y}" ]; then
    echo "The SYNC environment variable is unset or null, defaulting to 'async' mode".
    echo "Writes will not be immediately written to disk."
    /bin/sed -i "s/{{SYNC}}/async/g" /etc/exports
else
    echo "The SYNC environment variable is set, using 'sync' mode".
    echo "Writes will be immediately written to disk."
    /bin/sed -i "s/{{SYNC}}/sync/g" /etc/exports
fi

# Partially set 'unofficial Bash Strict Mode' as described here: http://redsymbol.net/articles/unofficial-bash-strict-mode/
# We don't set -e because the pidof command returns an exit code of 1 when the specified process is not found
# We expect this at times and don't want the script to be terminated when it occurs
set -uo pipefail
IFS=$'\n\t'

<<<<<<< Updated upstream
# This loop runs till until we've started up successfully
while true; do

    echo "In the loooop"

=======
# Mounting S3 Bucket
S3_ENDPOINT=https://s3.cubbit.eu
# if [ ! -z "$TENANT" ]; then
#     S3_ENDPOINT=https://s3.$TENANT.cubbit.eu
# fi

if [ ! -z "$S3_ACCESS_KEY_ID" -a ! -z "$S3_SECRET_ACCESS_KEY" ]; then
    echo "Set s3 access"
    set_s3_access $S3_ACCESS_KEY_ID $S3_SECRET_ACCESS_KEY
fi

mount_s3_bucket $S3_ENDPOINT $S3_BUCKET

# This loop runs till until we've started up successfully
while true; do

>>>>>>> Stashed changes
    # Check if NFS is running by recording it's PID (if it's not running $pid will be null):
    pid=$(pidof rpc.mountd)

    echo "PID: $pid"

    # If $pid is null, do this to start or restart NFS:
    while [ -z "$pid" ]; do
        echo "Displaying /etc/exports contents:"
        cat /etc/exports
        echo ""

        # Normally only required if v3 will be used
        # But currently enabled to overcome an NFS bug around opening an IPv6 socket
        echo "Starting rpcbind..."
        /sbin/rpcbind -w
        echo "Displaying rpcbind status..."
        /sbin/rpcinfo

        # Only required if v3 will be used
        # /usr/sbin/rpc.idmapd
        # /usr/sbin/rpc.gssd -v
        # /usr/sbin/rpc.statd

        echo "Starting NFS in the background..."
        /usr/sbin/rpc.nfsd --debug 8 --no-udp --no-nfs-version 3
        echo "Exporting File System..."
        if /usr/sbin/exportfs -rv; then
            /usr/sbin/exportfs
        else
            echo "Export validation failed, exiting..."
            exit 1
        fi
        echo "Starting Mountd in the background..."These
        /usr/sbin/rpc.mountd --debug all --no-udp --no-nfs-version 2 --no-nfs-version 3
        # --exports-file /etc/exports

        # Check if NFS is now running by recording it's PID (if it's not running $pid will be null):
        pid=$(pidof rpc.mountd)

        # If $pid is null, startup failed; log the fact and sleep for 2s
        # We'll then automatically loop through and try again
        if [ -z "$pid" ]; then
            echo "Startup of NFS failed, sleeping for 2s, then retrying..."
            sleep 2
        fi
    done

    # Break this outer loop once we've started up successfully
    # Otherwise, we'll silently restart and Docker won't know
    echo "Startup successful."
    break

done

while true; do

    # Check if NFS is STILL running by recording it's PID (if it's not running $pid will be null):
    pid=$(pidof rpc.mountd)
    # If it is not, lets kill our PID1 process (this script) by breaking out of this while loop:
    # This ensures Docker observes the failure and handles it as necessary
    if [ -z "$pid" ]; then
        echo "NFS has failed, exiting, so Docker can restart the container..."
        break
    fi

    # If it is, give the CPU a rest
    sleep 1

done

sleep 1

echo "Error"

exit 1

# Start the NFS server
# rpcbind || true
# exportfs -rv
# service nfs-kernel-server start

# Keep the container running
# tail -f /dev/null
#

# #!/usr/bin/env bash
#
# set -e
#
# ENABLE_CACHE=${ENABLE_CACHE:-0}
#
# S3_ACCESS_KEY_ID="74xUw+f4kaRaC8rT/KhQtNApWeI4yR/J"
# S3_SECRET_ACCESS_KEY="m85Nnyjm4TFU6y1txKAjebmOsVgt3yfGZaHhT7xaQ1o="
# S3_BUCKET="nfs-test"
# S3FS_PASSWD_FILE=/tmp/passwd-s3fs
#
# S3_ENDPOINT=https://s3.cubbit.eu
# if [ ! -z "$TENANT" ]; then
#     S3_ENDPOINT=https://s3.$TENANT.cubbit.eu
# fi
#
# NFS_MOUNTPOINT="/mnt/s3fs"
#
# function set_s3_access {
#     echo "$1:$2" >$S3FS_PASSWD_FILE
#     chmod 600 $S3FS_PASSWD_FILE
# }
#
# function mount_s3_bucket {
#     echo "Mounting s3 bucket '$2' from '$1'"
#     OPTIONS="passwd_file=$S3FS_PASSWD_FILE,umask=022,allow_other,url=$1"
#     if [ $ENABLE_CACHE -ne 0 ]; then
#         OPTIONS="$OPTIONS,use_cache=/tmp"
#     fi
#     s3fs -d -o "$OPTIONS" $2 $NFS_MOUNTPOINT/$3
# }
#
# # function nfsd_stop {
# #     echo "Received SIGINT or SIGTERM. Shutting down nfs"
# #     PID=$(cat $PID_FILE)
# #     kill -SIGTERM $PID
# #     wait $PID
# # }
#
# if [ ! -z "$S3_ACCESS_KEY_ID" -a ! -z "$S3_SECRET_ACCESS_KEY" ]; then
#     echo "Set s3 access"
#     set_s3_access $S3_ACCESS_KEY_ID $S3_SECRET_ACCESS_KEY
# fi
#
# mkdir -p $NFS_MOUNTPOINT
#
# mount_s3_bucket $S3_ENDPOINT $S3_BUCKET $FTP_USER
#
# # trap nfsd_stop SIGINT SIGTERM
#
# # Start NFS server
# # rpc.statd
# # rpc.nfsd -v
# #
# # echo "NFS started"
#
# # echo "Running $@"
# # $@
# # PID=$!
# # # echo $PID >"$PID_FILE"
# # echo $PID
# # wait $PID && exit $?
# #
#
