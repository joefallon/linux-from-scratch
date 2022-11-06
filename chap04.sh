# su to root with root's profile
su -l  

# create a basic directory layout (must be root)
mkdir -pv $LFS/etc
# mkdir: created directory '/mnt/lfs/etc'

mkdir -pv $LFS/var
# mkdir: created directory '/mnt/lfs/var'

mkdir -pv $LFS/usr/bin
# mkdir: created directory '/mnt/lfs/usr'
# mkdir: created directory '/mnt/lfs/usr/bin'

mkdir -pv $LFS/usr/lib
# mkdir: created directory '/mnt/lfs/usr/lib'

mkdir -pv $LFS/usr/sbin
# mkdir: created directory '/mnt/lfs/usr/sbin'

# the following are needed for cross compiling
ln -sv usr/bin $LFS/bin
# '/mnt/lfs/bin' -> 'usr/bin'

ln -sv usr/lib $LFS/lib
# '/mnt/lfs/lib' -> 'usr/lib'

ln -sv usr/sbin $LFS/sbin
# '/mnt/lfs/sbin' -> 'usr/sbin'

mkdir -pv $LFS/lib64
# mkdir: created directory '/mnt/lfs/lib64'

# create the cross compiler directory
mkdir -pv $LFS/tools
# mkdir: created directory '/mnt/lfs/tools'

# change the owner of the new directories to an unprivileged user
ls $LFS
# bin  etc  lib  lib64  lost+found  sbin  sources  tools  usr  var

chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}

chown --verbose --recursive joe $LFS/bin
# changed ownership of '/mnt/lfs/bin' from root to joe

chown --verbose --recursive joe $LFS/etc
# changed ownership of '/mnt/lfs/etc' from root to joe

chown --verbose --recursive joe $LFS/lib
# changed ownership of '/mnt/lfs/lib' from root to joe

chown --verbose --recursive joe $LFS/lib64
# changed ownership of '/mnt/lfs/lib64' from root to joe

chown --verbose --recursive joe $LFS/sbin
# changed ownership of '/mnt/lfs/sbin' from root to joe

chown --verbose --recursive joe $LFS/tools
# changed ownership of '/mnt/lfs/tools' from root to joe

chown --verbose --recursive joe $LFS/usr
# changed ownership of '/mnt/lfs/usr/sbin' from root to joe
# changed ownership of '/mnt/lfs/usr/lib' from root to joe
# changed ownership of '/mnt/lfs/usr/bin' from root to joe
# changed ownership of '/mnt/lfs/usr' from root to joe

chown --verbose --recursive joe $LFS/var
# changed ownership of '/mnt/lfs/var' from root to joe

# exit root
exit

# add the following to .bashrc for LFS
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
MAKEFLAGS='-j6'
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS
echo LFS=$LFS
echo LC_ALL=$LC_ALL
echo LFS_TGT=$LFS_TGT
echo PATH=$PATH
echo CONFIG_SITE=$CONFIG_SITE
echo MAKEFLAGS=$MAKEFLAGS
echo

# make the profile active
source ~/.bashrc


