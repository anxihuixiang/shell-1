#!/bin/bash
#--------------------------------------------------------
# Function: install php7 for centos7
# Update:   2018-11-07
# Author:   kirinlabs
#--------------------------------------------------------

APP=php-7.2.11.tar.gz
DIR=php-7.2.11

DOWNPATH=/root/download
[ ! -d $DOWNPATH ]&&{
	mkdir $DOWNPATH
}

cd $DOWNPATH


#Print debug information
function Debug(){
    echo ""
    echo -e "\033[37m[$(date)]\033[32m ::::::::::>>>>>-----------------<<<<<::::::::::\033[0m"
    echo -e "\033[37m[$(date)]\033[31m "$1"\033[0m"
    echo ""
}


#Installing wget
yum install -y wget


#Dwonload
[ ! -f ${DOWNPATH}/${APP} ]&&{
    wget -O ${DOWNPATH}/${APP} http://cn2.php.net/get/${APP}/from/this/mirror
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading ${APP} error...."
    exit 1
fi


#Installing dependencies
yum install -y wget gcc gcc-c++ autoconf automake cmake libtool make
yum install -y zlib-devel libxml2-devel libjpeg-turbo-devel libpng-devel gd-devel libiconv-devel freetype-devel libcurl-devel libxslt-devel openssl-devel readline-devel


#Create user
groupadd nobody
useradd -g nobody nobody
usermod -s /sbin/nologin nobody


cd $DOWNPATH
#Installing libiconv-1.14.tar.gz
[ ! -f ${DOWNPATH}/libiconv-1.14.tar.gz ]&&{
    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading libiconv-1.14.tar.gz error...."
    exit 1
fi
tar -zxvf libiconv-1.14.tar.gz
cd ${DOWNPATH}/libiconv-1.14
./configure --prefix=/usr/local/libiconv
make
make install


cd $DOWNPATH
#Installing libmcrypt-2.5.8.tar.gz
[ ! -f ${DOWNPATH}/libmcrypt-2.5.8.tar.gz ]&&{
    wget -O ${DOWNPATH}/libmcrypt-2.5.8.tar.gz https://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz/download
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading libmcrypt-2.5.8.tar.gz error...."
    exit 1
fi
tar -zxvf libmcrypt-2.5.8.tar.gz
cd ${DOWNPATH}/libmcrypt-2.5.8
./configure
make
make install


cd $DOWNPATH
#Installing mhash-0.9.9.9.tar.gz
[ ! -f ${DOWNPATH}/mhash-0.9.9.9.tar.gz ]&&{
    wget -O ${DOWNPATH}/mhash-0.9.9.9.tar.gz https://sourceforge.net/projects/mhash/files/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz/download
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading mhash-0.9.9.9.tar.gz error...."
    exit 1
fi
tar -zxvf mhash-0.9.9.9.tar.gz
cd ${DOWNPATH}/mhash-0.9.9.9
./configure
make
make install


cd $DOWNPATH
#Installing mcrypt-2.6.8.tar.gz
[ ! -f ${DOWNPATH}/mcrypt-2.6.8.tar.gz ]&&{
    wget -O ${DOWNPATH}/mcrypt-2.6.8.tar.gz https://sourceforge.net/projects/mcrypt/files/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz/download
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading mcrypt-2.6.8.tar.gz error...."
    exit 1
fi
tar -zxvf mcrypt-2.6.8.tar.gz
cd ${DOWNPATH}/mcrypt-2.6.8
LD_LIBRARY_PATH=/usr/local/lib ./configure
make
make install


#Tar php
cd $DOWNPATH
[ ! -d $DOWNPATH/${DIR} ]&&{
    tar -zxvf $APP
}
if [ $? -gt 1 ]
then
	Debug "PHP7 Installer: directory ${DIR} is not exists...."
    exit 404
fi

#Resolve error:Don’t know how to define struct flock on this system, set –enable-opcache=no
ln -s /usr/local/mysql/lib/libmysqlclient.so /usr/lib64/
ln -s /usr/local/mysql/lib/libmysqlclient.so.20 /usr/lib64/
LIBCONF="/etc/ld.so.conf.d/local.conf"
[ ! -f $LIBCONF ]&&{
    touch $LIBCONF
    echo "/usr/local/lib">$LIBCONF
    sed -i '$a /usr/local/lib64' $LIBCONF
    ldconfig -v
}


#Starting install
cd ${DOWNPATH}/${DIR}
./configure --prefix=/usr/local/php7 \
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--enable-mysqlnd \
--with-freetype-dir=/usr \
--with-gd \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-openssl \
--with-curl \
--with-libxml-dir \
--with-iconv-dir=/usr/local/libiconv \
--with-mcrypt \
--with-mhash \
--with-xmlrpc \
--with-xsl \
--enable-xml \
--disable-rpath \
--enable-safe-mod \
--enable-bcmath \
--with-readline \
--with-gc \
--enable-gd-native-ttf \
--enable-gd-jis-conv \
--enable-mbregex \
--enable-fpm \
--enable-short-tags \
--enable-sockets \
--enable-zend-multibyte \
--enable-zip \
--enable-pcntl \
--enable-soap \
--enable-mbstring \
--enable-static \
--enable-ftp \
--enable-opcache

make && make install
if [ $? -gt 0 ]
then
    Debug "PHP7 Installer: Installing ${APP} error...."
    exit 1
fi


#Copying config file
cp ./php.ini-production /usr/local/php7/lib/php.ini
cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf
cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf
if [ $? -gt 0 ]
then
    Debug "PHP7 Installer: Copying config files error...."
    exit 1
fi

#Set env
sed -i '$a PATH=$PATH:/usr/local/php7/bin' /etc/profile
sed -i '$a PATH=$PATH:/usr/local/php7/sbin' /etc/profile

. /etc/profile

#Starting php-fmp
/usr/local/php7/sbin/php-fpm
if [ $? -eq 0 ]
then
    ps -aux|grep php
fi
