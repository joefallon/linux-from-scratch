# create a new primary partition of type 83 (Linux), ~30GB
sudo cfdisk /dev/sda

# list the partitions, /dev/sda3
lsblk

# format the partition to ext4
sudo mkfs -v -t ext4 /dev/sda3


# export the LFS variable (must always be set)
export LFS=/mnt/lfs
echo $LFS

# create the directory to mount the linux from scratch partition
sudo mkdir -pv $LFS
# mkdir: created directory '/mnt/lfs'

# mount the linux from scratch partition
mount -o discard,noatime,nodiratime -v -t ext4 /dev/sda3 $LFS
# mount: /dev/sda3 mounted on /mnt/lfs.
# Note: the $LFS directory must be remounted on each reboot.

lsblk
# NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda      8:0    0   35G  0 disk
# ├─sda1   8:1    0  243M  0 part /boot
# ├─sda2   8:2    0  4.7G  0 part /
# └─sda3   8:3    0 30.1G  0 part /mnt/lfs

