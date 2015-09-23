#!/bin/bash
set -x
set -e
DIR=work_dir
if [ -d "$DIR" ]; then
    echo "Removing working directory: $DIR" 
    rm -rf "$DIR"
fi
mkdir -p $DIR
cd $DIR
apt-get install -y build-essential libldap2-dev dpkg-dev libdb5.1-dev subversion git
#svn co https://ltb-project.org/svn/openldap-ppolicy-check-password/trunk/
git clone https://github.com/MaheshIBM/ppolicy-check-password
git clone git://git.openldap.org/openldap.git
cd openldap
./configure
make
cd ../ppolicy-check-password
mkdir output
make install LDAP_INC="-I../openldap/include/ -I../openldap/servers/slapd" CONFIG="/etc/openldap/password.conf" CRACKLIB='' CRACKLIB_OPT='' CRACKLIB_LIB='' LIBDIR='output/'

cd ..

mkdir -p openldap-password-checker-1.0-1/DEBIAN
mkdir -p openldap-password-checker-1.0-1/etc/openldap
mkdir -p openldap-password-checker-1.0-1/usr/lib/ldap

cp ppolicy-check-password/password.conf openldap-password-checker-1.0-1/etc/openldap/password.conf
cp ppolicy-check-password/output/check_password.so openldap-password-checker-1.0-1/usr/lib/ldap/

echo "Package: openldap-password-checker
Version: 1.0-1
Section: base
Priority: optional
Architecture: amd64
Depends: slapd
Maintainer: Mahesh Sawaiker <maheshsa@us.ibm.com>
Description: Password checker module for openldap." > openldap-password-checker-1.0-1/DEBIAN/control 

dpkg-deb --build openldap-password-checker-1.0-1
