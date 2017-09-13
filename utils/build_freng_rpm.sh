#!/bin/bash

# ##################################################################
#
# Build udocker-freng rpm package
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

udocker_tarball_url()
{
    $REPO_DIR/utils/info.py | grep "udocker tarball:" | cut -f3- '-d '
}

#get_udocker_tarball()
#{
#    UDOCKER_TARBALL_URL=$(get_udocker_tarball_url)
#    /bin/rm $SOURCE_TARBALL 2> /dev/null
#    pushd $TMP_DIR
#    wget -oudocker_tarball.tgz $UDOCKER_TARBALL_URL
#    /bin/mv -f udocker_tarball.tgz $SOURCE_TARBALL
#    popd
#}

create_specfile() 
{
    cat - > $SPECFILE <<FRENG_SPEC
Name: udocker-freng
Summary: udocker-freng
Version: $VERSION
Release: $RELEASE
Source0: %{name}-%{version}.tar.gz
License: LGPLv2
ExclusiveOS: linux
Group: Applications/Emulators
Provides: %{name} = %{version}
URL: https://www.gitbook.com/book/indigo-dc/udocker/details
BuildRoot: %{_tmppath}/%{name}-%{version}-root
BuildRequires: kernel, kernel-devel, fileutils, findutils, bash, tar, gzip, wget
Requires: glibc, udocker

%define debug_package %{nil}

%description
Engine to provide chroot and mount like capabilities for containers execution in user mode within udocker using Fakechroot https://github.com/dex4er/fakechroot. 

%prep
#%setup -q -n $BASE_DIR
/bin/rm -Rf %{_builddir}/%{name}
mkdir %{_builddir}/%{name}

%build
cd %{_builddir}/%{name}
/bin/rm -f $SOURCE_TARBALL
wget -O$SOURCE_TARBALL $UDOCKER_TARBALL_URL
tar xzvf $SOURCE_TARBALL
/bin/rm -f COPYING LICENSE THANKS
wget https://raw.githubusercontent.com/dex4er/fakechroot/2.18/COPYING
wget https://raw.githubusercontent.com/dex4er/fakechroot/2.18/LICENSE
wget https://raw.githubusercontent.com/dex4er/fakechroot/2.18/THANKS

%install
rm -rf %{buildroot}
install -m 755 -D %{_builddir}/%{name}/udocker_dir/bin/patchelf-x86_64 %{buildroot}/%{_libexecdir}/udocker/patchelf-x86_64
echo "%{_libexecdir}/udocker/patchelf-x86_64" > %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-CentOS-6-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-CentOS-6-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-CentOS-6-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-CentOS-7-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-CentOS-7-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-CentOS-7-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Fedora-25-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-Fedora-25-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-Fedora-25-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Fedora-25-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-Fedora-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-Fedora-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Ubuntu-14-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-14-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-14-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Ubuntu-14-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Ubuntu-14-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-CentOS-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-CentOS-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Ubuntu-14-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-x86_64.so" >> %{_builddir}/%{name}/files.lst
install -m 755 -D %{_builddir}/%{name}/udocker_dir/lib/libfakechroot-Ubuntu-16-x86_64.so %{buildroot}/%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-16-x86_64.so
echo "%{_datarootdir}/udocker/lib/libfakechroot-Ubuntu-16-x86_64.so" >> %{_builddir}/%{name}/files.lst

%clean
rm -rf %{buildroot}

%files -f %{_builddir}/%{name}/files.lst
%defattr(-,root,root)

%doc %{name}/LICENSE %{name}/COPYING %{name}/THANKS

%changelog
* Tue Sep 12 2017 udocker maintainer <udocker@lip.pt> 1.1.0-1 
- Initial rpm package version

FRENG_SPEC
}

# ##################################################################
# MAIN
# ##################################################################

RELEASE="1"

utils_dir="$(dirname $(readlink -e $0))"
REPO_DIR="$(dirname $utils_dir)"
PARENT_DIR="$(dirname $REPO_DIR)"
BASE_DIR="udocker-freng"
VERSION="$(udocker_version)"

TMP_DIR="/tmp"
RPM_DIR="${HOME}/rpmbuild"
SOURCE_TARBALL="${RPM_DIR}/SOURCES/udocker-freng-${VERSION}.tar.gz"
SPECFILE="${RPM_DIR}/SPECS/udocker-freng.spec"

UDOCKER_TARBALL_URL=$(udocker_tarball_url)

cd $REPO_DIR
sanity_check
setup_env
create_specfile
rpmbuild -ba $SPECFILE
