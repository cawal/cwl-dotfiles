#!/bin/bash

set -u

section() {
  printf '\n===== %s =====\n' "$1"
}

run() {
  local description=$1
  shift

  section "$description"
  printf '+ %q' "$@"
  printf '\n'
  "$@" 2>&1 || true
}

section "collection metadata"
date -Is 2>&1 || true
printf 'user=%s\n' "${USER:-unknown}"
printf 'shell=%s\n' "${SHELL:-unknown}"

run "hostname" hostnamectl
run "os release" cat /etc/os-release
run "kernel" uname -a
run "cpu" lscpu
run "memory" free -h

run "block devices" lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL,SERIAL,VENDOR,TRAN,ROTA,RM
run "filesystems" findmnt --real --output TARGET,SOURCE,FSTYPE,SIZE,USED,AVAIL,OPTIONS
run "disk ids" ls -l /dev/disk/by-id/
run "partition tables" sudo parted -l
run "blkid" sudo blkid

run "lvm physical volumes" sudo pvs
run "lvm volume groups" sudo vgs
run "lvm logical volumes" sudo lvs -a -o +devices

run "zfs pools" sudo zpool status
run "zfs datasets" sudo zfs list -o name,used,available,refer,mountpoint,encryption,keylocation,keystatus

run "network links" ip -br link
run "network addresses" ip -br addr
run "default routes" ip route show default
run "wifi devices" nmcli device status

run "gpu pci devices" sh -c "lspci -nn | grep -Ei 'vga|3d|display'"
run "storage pci devices" sh -c "lspci -nn | grep -Ei 'sata|nvme|raid|storage'"
run "ubuntu drivers" ubuntu-drivers devices

run "secure boot" mokutil --sb-state
run "efi status" test -d /sys/firmware/efi

section "questions to answer manually"
cat <<'EOF'
preferred_hostname=
preferred_username=
ubuntu_version_or_iso=
wipe_entire_disk=yes/no
preserve_any_partitions=yes/no
desired_root_size=
desired_home_size=
desired_var_size=
desired_swap_size=
use_disk_encryption=yes/no
install_ssh_server=yes/no
ssh_password_login=yes/no
docker_expected=yes/no
notes=
EOF
