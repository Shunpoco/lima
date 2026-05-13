#!/bin/sh

# SPDX-FileCopyrightText: Copyright The Lima Authors
# SPDX-License-Identifier: Apache-2.0

set -eux

echo "35 dayo~~~~~~"

update_fuse_conf() {
	echo "UPDATE FUSE CONF"
	# Modify /etc/fuse.conf (/etc/fuse3.conf) to allow "-o allow_root"
	if [ "${LIMA_CIDATA_MOUNTS}" -gt 0 ]; then
		fuse_conf="/etc/fuse.conf"
		if [ -e /etc/fuse3.conf ]; then
			fuse_conf="/etc/fuse3.conf"
		fi
		if ! grep -q "^user_allow_other" "${fuse_conf}"; then
			echo "user_allow_other" >>"${fuse_conf}"
		fi
	fi

	# Some distribution like Ubuntu-25.10 has an apparmor rule for fusermount3. It causes SSHFS mount failed.
	if [ -e "/etc/apparmor.d/fusermount3" -a ! -e "/etc/apparmor.d/local/fusermount3" ]; then
		echo "AAAA"
		cat >> "/etc/apparmor.d/local/fusermount3" << EOF
mount fstype=@{fuse_types} options=(nosuid,nodev) options in (ro,rw,noatime,dirsync,nodiratime,noexec,sync) -> @{HOME},
umount @{HOME},
EOF
		apparmor_parser -r /etc/apparmor.d/fusermount3
	fi
}

# update_fuse_conf has to be called after installing all the packages,
# otherwise apt-get fails with conflict
if [ "${LIMA_CIDATA_MOUNTTYPE}" = "reverse-sshfs" ]; then
	update_fuse_conf
fi

SETUP_DNS=0
if [ -n "${LIMA_CIDATA_UDP_DNS_LOCAL_PORT}" ] && [ "${LIMA_CIDATA_UDP_DNS_LOCAL_PORT}" -ne 0 ]; then
	SETUP_DNS=1
fi
if [ -n "${LIMA_CIDATA_TCP_DNS_LOCAL_PORT}" ] && [ "${LIMA_CIDATA_TCP_DNS_LOCAL_PORT}" -ne 0 ]; then
	SETUP_DNS=1
fi
if [ "${SETUP_DNS}" = 1 ]; then
	# Try to setup iptables rule again, in case we just installed iptables
	"${LIMA_CIDATA_MNT}/boot.Linux/09-host-dns-setup.sh"
fi
