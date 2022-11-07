# Change the ownership of the $LFS/* directories to 
# user root by running the following command:
sudo chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools,lib64}

ls -al
# total 48
# drwxr-xr-x 9 root root  4096 Nov  6 13:37 .
# drwxr-xr-x 3 root root  4096 Nov  6 10:04 ..
# lrwxrwxrwx 1 root root     7 Nov  6 10:46 bin -> usr/bin
# drwxr-xr-x 2 root root  4096 Nov  6 15:04 etc
# lrwxrwxrwx 1 root root     7 Nov  6 10:47 lib -> usr/lib
# drwxr-xr-x 2 root root  4096 Nov  6 14:53 lib64
# drwx------ 2 root root 16384 Nov  6 09:58 lost+found
# lrwxrwxrwx 1 root root     8 Nov  6 10:47 sbin -> usr/sbin
# drwxrwxrwt 2 joe  root  4096 Nov  6 16:21 sources
# drwxr-xr-x 8 root root  4096 Nov  6 14:13 tools
# drwxr-xr-x 9 root root  4096 Nov  6 16:00 usr
# drwxr-xr-x 3 root root  4096 Nov  6 15:04 var

sudo mkdir -pv $LFS/dev
# mkdir: created directory '/mnt/lfs/dev'
sudo mkdir -pv $LFS/proc
# mkdir: created directory '/mnt/lfs/proc'
sudo mkdir -pv $LFS/sys
# mkdir: created directory '/mnt/lfs/sys'
sudo mkdir -pv $LFS/run
# mkdir: created directory '/mnt/lfs/run'

sudo mount -v --bind /dev $LFS/dev
# mount: /dev bound on /mnt/lfs/dev.

sudo mount -v --bind /dev/pts $LFS/dev/pts
# mount: /dev/pts bound on /mnt/lfs/dev/pts.
sudo mount -vt proc proc $LFS/proc
# mount: proc mounted on /mnt/lfs/proc.
sudo mount -vt sysfs sysfs $LFS/sys
# mount: sysfs mounted on /mnt/lfs/sys.
sudo mount -vt tmpfs tmpfs $LFS/run
# mount: tmpfs mounted on /mnt/lfs/run.

su -l
if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
else
  mount -t tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
exit

sudo chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash --login

mkdir -pv /{boot,home,mnt,opt,srv}
# mkdir: created directory '/boot'
# mkdir: created directory '/home'
# mkdir: created directory '/mnt'
# mkdir: created directory '/opt'
# mkdir: created directory '/srv'

mkdir -pv /etc/{opt,sysconfig}
# mkdir: created directory '/etc/opt'
# mkdir: created directory '/etc/sysconfig'
mkdir -pv /lib/firmware
# mkdir: created directory '/lib/firmware'
mkdir -pv /media/{floppy,cdrom}
# mkdir: created directory '/media'
# mkdir: created directory '/media/floppy'
# mkdir: created directory '/media/cdrom'
mkdir -pv /usr/{,local/}{include,src}
# mkdir: created directory '/usr/src'
# mkdir: created directory '/usr/local'
# mkdir: created directory '/usr/local/include'
# mkdir: created directory '/usr/local/src'
mkdir -pv /usr/local/{bin,lib,sbin}
# mkdir: created directory '/usr/local/bin'
# mkdir: created directory '/usr/local/lib'
# mkdir: created directory '/usr/local/sbin'
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
# mkdir: created directory '/usr/share/color'
# mkdir: created directory '/usr/share/dict'
# mkdir: created directory '/usr/local/share'
# mkdir: created directory '/usr/local/share/color'
# mkdir: created directory '/usr/local/share/dict'
# mkdir: created directory '/usr/local/share/doc'
# mkdir: created directory '/usr/local/share/info'
# mkdir: created directory '/usr/local/share/locale'
# mkdir: created directory '/usr/local/share/man'
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
# mkdir: created directory '/usr/share/zoneinfo'
# mkdir: created directory '/usr/local/share/misc'
# mkdir: created directory '/usr/local/share/terminfo'
# mkdir: created directory '/usr/local/share/zoneinfo'
mkdir -pv /usr/{,local/}share/man/man{1..8}
# mkdir: created directory '/usr/share/man/man2'
# mkdir: created directory '/usr/share/man/man6'
# mkdir: created directory '/usr/local/share/man/man1'
# mkdir: created directory '/usr/local/share/man/man2'
# mkdir: created directory '/usr/local/share/man/man3'
# mkdir: created directory '/usr/local/share/man/man4'
# mkdir: created directory '/usr/local/share/man/man5'
# mkdir: created directory '/usr/local/share/man/man6'
# mkdir: created directory '/usr/local/share/man/man7'
# mkdir: created directory '/usr/local/share/man/man8'
mkdir -pv /var/{cache,local,log,mail,opt,spool}
# mkdir: created directory '/var/cache'
# mkdir: created directory '/var/local'
# mkdir: created directory '/var/log'
# mkdir: created directory '/var/mail'
# mkdir: created directory '/var/opt'
# mkdir: created directory '/var/spool'
mkdir -pv /var/lib/{color,misc,locate}
# mkdir: created directory '/var/lib/color'
# mkdir: created directory '/var/lib/misc'

ln -sfv /run /var/run
# '/var/run' -> '/run'
ln -sfv /run/lock /var/lock
# '/var/lock' -> '/run/lock'

install -dv -m 0750 /root
# install: creating directory '/root'
install -dv -m 1777 /tmp /var/tmp
# install: creating directory '/tmp'
# install: creating directory '/var/tmp'

ln -sv /proc/self/mounts /etc/mtab
# '/etc/mtab' -> '/proc/self/mounts'

cat > /etc/hosts << EOF
127.0.0.1  localhost $(hostname)
::1        localhost
EOF

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/usr/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/usr/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/usr/bin/false
systemd-network:x:76:76:systemd Network Management:/:/usr/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/usr/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/usr/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
systemd-oom:x:81:81:systemd Out Of Memory Daemon:/:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
uuidd:x:80:
systemd-oom:x:81:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

exec /usr/bin/bash --login

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
# changed group of '/var/log/lastlog' from root to utmp
chmod -v 664  /var/log/lastlog
# mode of '/var/log/lastlog' changed from 0644 (rw-r--r--) to 0664 (rw-rw-r--)
chmod -v 600  /var/log/btmp
# mode of '/var/log/btmp' changed from 0644 (rw-r--r--) to 0600 (rw-------)

cd sources

# Gettext-0.21.1
# The Gettext package contains utilities for internationalization and 
# localization. These allow programs to be compiled with NLS (Native 
# Language Support), enabling them to output messages in the user's 
# native language.
tar -xvf gettext-0.21.1.tar.xz
cd gettext-0.21.1
./configure --disable-shared
make -j6 -l6
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
# 'gettext-tools/src/msgfmt' -> '/usr/bin/msgfmt'
# 'gettext-tools/src/msgmerge' -> '/usr/bin/msgmerge'
# 'gettext-tools/src/xgettext' -> '/usr/bin/xgettext'
cd ..
rm -rf gettext-0.21.1

# Bison-3.8.2
# The Bison package contains a parser generator.
tar -xvf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

make -j6 -l6
make install

cd ..
rm -rf bison-3.8.2

# Perl-5.36.0
# The Perl package contains the Practical Extraction and Report Language.
tar -xvf perl-5.36.0.tar.xz
cd perl-5.36.0

sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.36/core_perl     \
             -Darchlib=/usr/lib/perl5/5.36/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.36/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.36/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl

make -j6 -l6
make install
cd ..
rm -rf perl-5.36.0

# Python-3.11.0
# The Python 3 package contains the Python development environment.
tar -xvf Python-3.11.0.tar.xz
cd Python-3.11.0

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make -j6 -l6
make install
cd ..
rm -rf Python-3.11.0

# Texinfo-6.8
# The Texinfo package contains programs for reading, writing, and converting info pages.
tar -xvf texinfo-6.8.tar.xz
cd texinfo-6.8
./configure --prefix=/usr
make -j6 -l6
make install
cd ..
rm -rf texinfo-6.8

# Util-linux-2.38.1
# The Util-linux package contains miscellaneous utility programs.
tar -xvf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1
mkdir -pv /var/lib/hwclock
# mkdir: created directory '/var/lib/hwclock'

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --libdir=/usr/lib    \
            --docdir=/usr/share/doc/util-linux-2.38.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            runstatedir=/run

make -j6 -l6
make install
cd ..
rm -rf util-linux-2.38.1

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools












