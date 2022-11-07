echo $LFS
# /mnt/lfs

# create a build directory
sudo mkdir -pv $LFS/build
# mkdir: created directory '/mnt/lfs/build'

chown --verbose --recursive joe $LFS/build
# changed ownership of '/mnt/lfs/build' from root to joe

cd $LFS/build
pwd
# /mnt/lfs/build

sudo chown --verbose --recursive joe $LFS/sources
cd $LFS/sources
pwd
# /mnt/lfs/sources

tar -xvf binutils-2.39.tar.xz
ls
# ...
# binutils-2.39
# ...

cd binutils-2.39
pwd
# /mnt/lfs/sources/binutils-2.39

sudo rm -rf $LFS/build
ls $LFS
# bin  etc  lib  lib64  lost+found  sbin  sources  tools  usr  var

mkdir -v build
# mkdir: created directory 'build'
cd build/

# configure binutils
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror

# compile. limit jobs to 6. limit load to 6.
make -j6 -l6
# install binutils
make install

pwd
# /mnt/lfs/sources/binutils-2.39/build
cd $LFS/sources
rm -rf binutils-2.39/

# compile gcc (pass 1)
tar -xvf gcc-12.2.0.tar.xz
cd gcc-12.2.0/

tar -xvf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
# renamed 'mpfr-4.1.0' -> 'mpfr'

tar -xvf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
# renamed 'gmp-6.2.1' -> 'gmp'

tar -xvf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
# renamed 'mpc-1.2.1' -> 'mpc'

# On x86_64 hosts, set the default directory name for 64-bit libraries to lib
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
# mkdir: created directory 'build'
cd build

# configure gcc
../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.36 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-decimal-float   \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

make -j6 -l6
make install


# Create a full version of the internal header using a command that is 
# identical to what the GCC build system does in normal circumstances
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

cd $LFS/sources
rm -rf gcc-12.2.0

tar -xvf linux-6.0.6.tar.xz
cd linux-6.0.6/

# Make sure there are no stale files embedded in the package.
make mrproper

# Install Linux API headers.
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
cd $LFS/source
rm -rf linux-6.0.6

# Installation of glibc
tar -xvf glibc-2.36.tar.xz
cd glibc-2.36/

# First, create a symbolic link for LSB compliance. Additionally, 
# for x86_64, create a compatibility symbolic link required for 
# proper operation of the dynamic library loader.
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac
# '/mnt/lfs/lib64/ld-linux-x86-64.so.2' -> '../lib/ld-linux-x86-64.so.2'
# '/mnt/lfs/lib64/ld-lsb-x86-64.so.3' -> '../lib/ld-linux-x86-64.so.2'

# Fix an issue building Glibc with parallel jobs and make-4.4 or later.
sed '/MAKEFLAGS :=/s/)r/) -r/' -i Makerules
# sed: can't read Makerules: No such file or directory

# Some of the Glibc programs use the non-FHS-compliant /var/db directory 
# to store their runtime data. Apply the following patch to make such 
# programs store their runtime data in the FHS-compliant locations.
patch -Np1 -i ../glibc-2.36-fhs-1.patch

mkdir -v build
# mkdir: created directory 'build'
cd build

echo "rootsbindir=/usr/sbin" > configparms

sudo aptitude install gawk

# configure glibc
../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib

# make and install
make -j6 -l6
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
# [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]

rm -v a.out
# rm: remove regular file 'a.out'? y
# removed 'a.out'

# finalize the installation of the limits.h header
$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders

cd $LFS/sources/
rm -rf glibc-2.36

# Libstdc++ from GCC-12.2.0
tar -xvf gcc-12.2.0.tar.xz
cd gcc-12.2.0
mkdir -v build
# mkdir: created directory 'build'
cd build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0

make -j6 -l6
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la

cd $LFS/sources
rm -rf gcc-12.2.0

# compile M4-1.4.19
# The M4 package contains a macro processor.
tar -xvf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf m4-1.4.19

# Ncurses-6.3
# The Ncurses package contains libraries for terminal-independent handling of character screens.
tar -xvf ncurses-6.3.tar.gz
cd ncurses-6.3/
sed -i s/mawk// configure

mkdir build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            --enable-widec

make -j6 -l6
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
cd ..
rm -rf ncurses-6.3

# Bash-5.2
# The Bash package contains the Bourne-Again SHell.
tar -xvf bash-5.2.tar.gz
cd bash-5.2/

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make -j6 -l6
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh
# '/mnt/lfs/bin/sh' -> 'bash'
cd ..
rm -rf bash-5.2

# Coreutils-9.1
# The Coreutils package contains utilities for showing and setting 
# the basic system characteristics.
tar -xvf coreutils-9.1.tar.xz
cd coreutils-9.1

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make -j6 -l6
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
# renamed '/mnt/lfs/usr/bin/chroot' -> '/mnt/lfs/usr/sbin/chroot'
mkdir -pv $LFS/usr/share/man/man8
# mkdir: created directory '/mnt/lfs/usr/share/man/man8'
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
# renamed '/mnt/lfs/usr/share/man/man1/chroot.1' -> '/mnt/lfs/usr/share/man/man8/chroot.8'
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
cd ..
rm -rf coreutils-9.1

# Diffutils-3.8
# The Diffutils package contains programs that show the differences 
# between files or directories.
tar -xvf diffutils-3.8.tar.xz
cd diffutils-3.8/

./configure --prefix=/usr --host=$LFS_TGT
make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf diffutils-3.8

# File-5.43
# The File package contains a utility for determining the type of a given file or files.
tar -xvf file-5.43.tar.gz
cd file-5.43/

mkdir -v build
# mkdir: created directory 'build'
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make -j6 -l6
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make -j6 -l6 FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la
# rm: remove regular file '/mnt/lfs/usr/lib/libmagic.la'? y
# removed '/mnt/lfs/usr/lib/libmagic.la'
cd ..
rm -rf file-5.43

# Findutils-4.9.0
# The Findutils package contains programs to find files.
tar -xvf findutils-4.9.0.tar.xz
cd findutils-4.9.0/

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf findutils-4.9.0

# Gawk-5.2.0
# The Gawk package contains programs for manipulating text files.
tar -xvf gawk-5.2.0.tar.xz
cd gawk-5.2.0/
sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf gawk-5.2.0

# Grep-3.8
# The Grep package contains programs for searching through the contents of files.
tar -xvf grep-3.8.tar.xz
cd grep-3.8/

./configure --prefix=/usr   \
            --host=$LFS_TGT

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf grep-3.8

# Gzip-1.12
# The Gzip package contains programs for compressing and decompressing files.
tar -xvf gzip-1.12.tar.xz
cd gzip-1.12/
./configure --prefix=/usr --host=$LFS_TGT
make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf gzip-1.12

# Make-4.4
# The Make package contains a program for controlling the 
# generation of executables and other non-source files of 
# a package from source files.
tar -xvf make-4.4.tar.gz
cd make-4.4/

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf make-4.4

# Patch-2.7.6
# The Patch package contains a program for modifying or creating 
# files by applying a “patch” file typically created by the diff 
# program.
tar -xvf patch-2.7.6.tar.xz
cd patch-2.7.6/

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf patch-2.7.6

# Sed-4.8
# The Sed package contains a stream editor.
tar -xvf sed-4.8.tar.xz
cd sed-4.8/
./configure --prefix=/usr --host=$LFS_TGT
make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf sed-4.8

# Tar-1.34
# The Tar package provides the ability to create tar archives as 
# well as perform various other kinds of archive manipulation. Tar 
# can be used on previously created archives to extract files, to 
# store additional files, or to update or list files which were 
# already stored.
tar -xvf tar-1.34.tar.xz
cd tar-1.34/
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make -j6 -l6
make DESTDIR=$LFS install
cd ..
rm -rf tar-1.34

# Xz-5.2.7
# The Xz package contains programs for compressing and decompressing
# files. It provides capabilities for the lzma and the newer xz 
# compression formats. Compressing text files with xz yields a better 
# compression percentage than with the traditional gzip or bzip2 commands.
tar -xvf xz-5.2.7.tar.xz
cd xz-5.2.7/

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.7

make -j6 -l6
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la
# rm: remove regular file '/mnt/lfs/usr/lib/liblzma.la'? y
# removed '/mnt/lfs/usr/lib/liblzma.la'
cd ..
rm -rf xz-5.2.7

# Binutils-2.39 - Pass 2
# The Binutils package contains a linker, an assembler, and other 
# tools for handling object files.
tar -xvf binutils-2.39.tar.xz
cd binutils-2.39/
sed '6009s/$add_dir//' -i ltmain.sh
mkdir -v build
# mkdir: created directory 'build'
cd build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd

make -j6 -l6
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
# rm: remove regular file '/mnt/lfs/usr/lib/libbfd.a'? y
# removed '/mnt/lfs/usr/lib/libbfd.a'
# rm: remove regular file '/mnt/lfs/usr/lib/libbfd.la'? y
# removed '/mnt/lfs/usr/lib/libbfd.la'
# rm: remove regular file '/mnt/lfs/usr/lib/libctf.a'? y
# removed '/mnt/lfs/usr/lib/libctf.a'
# rm: remove regular file '/mnt/lfs/usr/lib/libctf.la'? y
# removed '/mnt/lfs/usr/lib/libctf.la'
# rm: remove regular file '/mnt/lfs/usr/lib/libctf-nobfd.a'? y
# removed '/mnt/lfs/usr/lib/libctf-nobfd.a'
# rm: remove regular file '/mnt/lfs/usr/lib/libctf-nobfd.la'? y
# removed '/mnt/lfs/usr/lib/libctf-nobfd.la'
# rm: remove regular file '/mnt/lfs/usr/lib/libopcodes.a'? y
# removed '/mnt/lfs/usr/lib/libopcodes.a'
# rm: remove regular file '/mnt/lfs/usr/lib/libopcodes.la'? y
# removed '/mnt/lfs/usr/lib/libopcodes.la'

cd ..
cd ..
rm -rf binutils-2.39

# GCC-12.2.0 - Pass 2
# The GCC package contains the GNU compiler collection, which 
# includes the C and C++ compilers.
tar -xvf gcc-12.2.0.tar.xz
cd gcc-12.2.0/
tar -xvf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
# renamed 'mpfr-4.1.0' -> 'mpfr'
tar -xvf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
# renamed 'gmp-6.2.1' -> 'gmp'
tar -xvf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
# renamed 'mpc-1.2.1' -> 'mpc'

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
# mkdir: created directory 'build'
cd build

../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++

make -j6 -l6
make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc
# '/mnt/lfs/usr/bin/cc' -> 'gcc'
cd ..
cd ..
rm -rf gcc-12.2.0















