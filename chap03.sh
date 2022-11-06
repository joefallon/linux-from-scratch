# create a directory for the source files
sudo mkdir -v $LFS/sources
# mkdir: created directory '/mnt/lfs/sources'

# make the directory writable and sticky
sudo chmod -v a+wt $LFS/sources
# mode of '/mnt/lfs/sources' changed from 0755 (rwxr-xr-x) to 1777 (rwxrwxrwt)

# download the package list
wget https://www.linuxfromscratch.org/lfs/view/systemd/wget-list-systemd

# download the md5sums
wget https://www.linuxfromscratch.org/lfs/view/systemd/md5sums

# download the sources using the package list
wget --input-file=wget-list-systemd --continue --directory-prefix=$LFS/sources

ls /mnt/lfs/sources
# acl-2.3.1.tar.xz                  glibc-2.36.tar.xz            ncurses-6.3.tar.gz
# attr-2.5.1.tar.gz                 gmp-6.2.1.tar.xz             ninja-1.11.1.tar.gz
# autoconf-2.71.tar.xz              gperf-3.1.tar.gz             openssl-3.0.7.tar.gz
# automake-1.16.5.tar.xz            grep-3.8.tar.xz              patch-2.7.6.tar.xz
# bash-5.2.tar.gz                   groff-1.22.4.tar.gz          perl-5.36.0.tar.xz
# bash-5.2-upstream_fixes-1.patch   grub-2.06.tar.xz             pkg-config-0.29.2.tar.gz
# bc-6.0.4.tar.xz                   gzip-1.12.tar.xz             procps-ng-4.0.1.tar.xz
# binutils-2.39.tar.xz              iana-etc-20221025.tar.gz     psmisc-23.5.tar.xz
# bison-3.8.2.tar.xz                inetutils-2.4.tar.xz         python-3.11.0-docs-html.tar.bz2
# bzip2-1.0.8-install_docs-1.patch  intltool-0.51.0.tar.gz       Python-3.11.0.tar.xz
# bzip2-1.0.8.tar.gz                iproute2-6.0.0.tar.xz        readline-8.2.tar.gz
# check-0.15.2.tar.gz               Jinja2-3.1.2.tar.gz          readline-8.2-upstream_fix-1.patch
# coreutils-9.1-i18n-1.patch        kbd-2.5.1-backspace-1.patch  sed-4.8.tar.xz
# coreutils-9.1.tar.xz              kbd-2.5.1.tar.xz             shadow-4.12.3.tar.xz
# dbus-1.14.4.tar.xz                kmod-30.tar.xz               systemd-252.tar.gz
# dejagnu-1.6.3.tar.gz              less-608.tar.gz              systemd-man-pages-252.tar.xz
# diffutils-3.8.tar.xz              libcap-2.66.tar.xz           tar-1.34.tar.xz
# e2fsprogs-1.46.5.tar.gz           libffi-3.4.4.tar.gz          tcl8.6.12-html.tar.gz
# elfutils-0.187.tar.bz2            libpipeline-1.5.6.tar.gz     tcl8.6.12-src.tar.gz
# expat-2.5.0.tar.xz                libtool-2.4.7.tar.xz         texinfo-6.8.tar.xz
# expect5.45.4.tar.gz               linux-6.0.6.tar.xz           tzdata2022f.tar.gz
# file-5.43.tar.gz                  m4-1.4.19.tar.xz             util-linux-2.38.1.tar.xz
# findutils-4.9.0.tar.xz            make-4.4.tar.gz              vim-9.0.0739.tar.gz
# flex-2.6.4.tar.gz                 man-db-2.11.0.tar.xz         wheel-0.37.1.tar.gz
# gawk-5.2.0.tar.xz                 man-pages-6.01.tar.xz        XML-Parser-2.46.tar.gz
# gcc-12.2.0.tar.xz                 MarkupSafe-2.1.1.tar.gz      xz-5.2.7.tar.xz
# gdbm-1.23.tar.gz                  meson-0.63.3.tar.gz          zlib-1.2.13.tar.xz
# gettext-0.21.1.tar.xz             mpc-1.2.1.tar.gz             zstd-1.5.2.tar.gz
# glibc-2.36-fhs-1.patch            mpfr-4.1.0.tar.xz            zstd-1.5.2-upstream_fixes-1.patch

# TODO: Research each of these packages and learn about them in detail.

# check free space
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# udev            2.0G     0  2.0G   0% /dev
# tmpfs           394M  548K  393M   1% /run
# /dev/sda2       4.6G  2.9G  1.5G  67% /
# tmpfs           2.0G     0  2.0G   0% /dev/shm
# tmpfs           5.0M     0  5.0M   0% /run/lock
# /dev/sda1       230M   80M  134M  38% /boot
# tmpfs           394M     0  394M   0% /run/user/1000
# /dev/sda3        30G  477M   28G   2% /mnt/lfs

# check md5 sums
pushd $LFS/sources
    md5sum -c ~/projects/linux-from-scratch/md5sums
popd

# acl-2.3.1.tar.xz: OK
# attr-2.5.1.tar.gz: OK
# autoconf-2.71.tar.xz: OK
# automake-1.16.5.tar.xz: OK
# bash-5.2.tar.gz: OK
# bc-6.0.4.tar.xz: OK
# ...all are OK

# change the owner of the downloaded files to root
sudo chown root:root -v $LFS/sources/*


