#!/bin/bash

# ##################################################################
#
# Build udocker-preng rpm package
#
# ##################################################################

sanity_check() 
{
    if [ ! -f "$REPO_DIR/udocker.py" ] ; then
        echo "$REPO_DIR/udocker.py not found aborting"
        exit 1
    fi
}

setup_env()
{
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    if [ ! -e ~/.rpmmacros ]; then
        echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
    fi
}

udocker_version()
{
    $REPO_DIR/utils/info.py | grep "udocker version:" | cut -f3- '-d ' | cut -f1 '-d-'
}

patch_proot_source2()
{
    echo "patch_proot_source2"

    pushd "$TMP_DIR/$BASE_DIR/src/tracee"

    if [ -e "event.patch" ] ; then
        echo "patch proot source2 already applied: $PWD/event.patch"
        return
    fi

    cp ${utils_dir}/proot_event.patch event.patch
    patch < event.patch
    popd
}

patch_proot_source3()
{
    echo "patch_proot_source3"

    pushd "$TMP_DIR/$BASE_DIR/src/path"

    if [ -e "temp.patch" ] ; then
        echo "patch proot source3 already applied: $PWD/temp.patch"
        return
    fi

    cp ${utils_dir}/proot_temp.patch temp.patch
    patch < temp.patch
    popd
}

create_source_tarball()
{
    /bin/rm $SOURCE_TARBALL 2> /dev/null
    pushd $TMP_DIR
    /bin/rm -Rf PRoot
    #git clone --branch v5.1.0 --depth=1 https://github.com/proot-me/PRoot 
    git clone https://github.com/proot-me/PRoot
    pushd PRoot
    git checkout v5.1.0
    popd
    /bin/mv PRoot $BASE_DIR
    patch_proot_source2
    patch_proot_source3
    tar czvf $SOURCE_TARBALL $BASE_DIR
    /bin/rm -Rf $BASE_DIR
    popd
}

create_specfile() 
{
    cat - > $SPECFILE <<PRENG_SPEC
Name: udocker-preng
Summary: udocker-preng
Version: $VERSION
Release: $RELEASE
Source0: %{name}-%{version}.tar.gz
License: GPLv2
ExclusiveOS: linux
Group: Applications/Emulators
Provides: %{name} = %{version}
URL: https://www.gitbook.com/book/indigo-dc/udocker/details
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildRequires: kernel, kernel-devel, fileutils, findutils, bash, tar, gzip, make, libtalloc, libtalloc-devel, gcc, binutils, glibc, glibc-devel, glibc-headers
Requires: libtalloc, glibc, udocker

%define debug_package %{nil}

%description
Engine to provide chroot and mount like capabilities for containers execution in user mode within udocker using PRoot https://github.com/proot-me. PRoot is a user-space implementation of chroot, mount --bind, and binfmt_misc. Technically PRoot relies on ptrace, an unprivileged system-call available in every Linux kernel.

%prep
%setup -q -n $BASE_DIR

%build
make -C src

%install
rm -rf %{buildroot}
BITS=\$(getconf LONG_BIT)
MACH=\$(uname -m)
if [ "\$BITS" = "64" -a "\$MACH" = "x86_64" ]; then
    PROOT="proot-x86_64"
elif [ "\$BITS" = "32" -a "\$MACH" = "x86_64" ]; then
    PROOT="proot-x86"
elif [ "\$BITS" = "32" -a \\( "\$MACH" = "i386" -o "\$MACH" = "i586" -o "\$MACH" = "i686" \\) ]; then
    PROOT="proot-x86"
elif [ "\$BITS" = "64" -a "\${MACH:0:3}" = "arm" ]; then
    PROOT="proot-arm64"
elif [ "\$BITS" = "32" -a "\${MACH:0:3}" = "arm" ]; then
    PROOT="proot-arm"
else
    PROOT="proot"
fi
install -m 755 -D %{_builddir}/%{name}/src/proot %{buildroot}/%{_libexecdir}/udocker/\$PROOT
echo "%{_libexecdir}/udocker/\$PROOT" > %{_builddir}/%{name}/files.lst

%clean
rm -rf %{buildroot}

%files -f %{_builddir}/%{name}/files.lst
%defattr(-,root,root)

%doc README.rst AUTHORS COPYING

%changelog
* Tue Sep 12 2017 udocker maintainer <udocker@lip.pt> 1.1.0-1 
- Repackaging for udocker 1.1.0
* Wed Mar 22 2017 udocker maintainer <udocker@lip.pt> 1.0.3-1 
- Repackaging for udocker 1.0.3
* Tue Feb 14 2017 udocker maintainer <udocker@lip.pt> 1.0.2-1 
- Fix accelerated seccomp on kernels >= 4.8.0
* Mon Jan  9 2017 udocker maintainer <udocker@lip.pt> 1.0.1-1 
- Initial rpm package version

PRENG_SPEC
}

# ##################################################################
# MAIN
# ##################################################################

RELEASE="1"

utils_dir="$(dirname $(readlink -e $0))"
REPO_DIR="$(dirname $utils_dir)"
PARENT_DIR="$(dirname $REPO_DIR)"
BASE_DIR="udocker-preng"
VERSION="$(udocker_version)"

TMP_DIR="/tmp"
RPM_DIR="${HOME}/rpmbuild"
SOURCE_TARBALL="${RPM_DIR}/SOURCES/udocker-preng-${VERSION}.tar.gz"
SPECFILE="${RPM_DIR}/SPECS/udocker-preng.spec"

cd $REPO_DIR
sanity_check
setup_env
create_source_tarball
create_specfile
rpmbuild -ba $SPECFILE
