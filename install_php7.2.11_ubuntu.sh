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
    echo "\033[37m[$(date)]\033[32m ::::::::::>>>>>-----------------<<<<<::::::::::\033[0m"
    echo "\033[37m[$(date)]\033[31m "$1"\033[0m"
    echo ""
}

#Installing wget
apt-get install -y wget

#Dwonloading php-7.1.13.tar.gz
[ ! -f ${DOWNPATH}/${APP} ]&&{
    wget -O ${DOWNPATH}/${APP} http://cn2.php.net/get/${APP}/from/this/mirror
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading ${APP} error...."
    exit 404
fi


#Installing dependencies
apt-get install -y gcc g++ autoconf automake cmake
apt-get install -y libreadline-dev libreadline6-dev
apt-get install -y zlib1g zlib1g-dev libxml2 libxml2-dev libjpeg-dev libpng-dev libgd-dev libfreetype6-dev
apt-get install -y openssl libssl-dev libcurl4-openssl-dev libxslt-dev libxslt1-dev


#Create user
groupadd nobody
useradd -g nobody nobody
usermod -s /sbin/nologin nobody


#Installing libiconv-1.14.tar.gz
[ ! -f ${DOWNPATH}/libiconv-1.14.tar.gz ]&&{
    wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading libiconv-1.14.tar.gz error...."
    exit 404
fi
cd $DOWNPATH
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
    exit 404
fi
tar -zxvf libmcrypt-2.5.8.tar.gz
cd ${DOWNPATH}/libmcrypt-2.5.8
./configure
make
make install

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8


cd $DOWNPATH
#Installing mhash-0.9.9.9.tar.gz
[ ! -f ${DOWNPATH}/mhash-0.9.9.9.tar.gz ]&&{
    wget -O ${DOWNPATH}/mhash-0.9.9.9.tar.gz https://sourceforge.net/projects/mhash/files/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz/download
}
if [ $? -gt 1 ]
then
    Debug "PHP7 Installer: Downloading mhash-0.9.9.9.tar.gz error...."
    exit 404
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
    exit 404
fi
tar -zxvf mcrypt-2.6.8.tar.gz
cd ${DOWNPATH}/mcrypt-2.6.8
LD_LIBRARY_PATH=/usr/local/lib ./configure
make
make install


#Tar php
cd $DOWNPATH
[ ! -d $DOWNPATH/${DIR} ]&&{
    tar -zxvf ${APP}
}
if [ $? -gt 1 ]
then
	Debug "PHP7 Installer: directory ${DIR} is not exists...."
    exit 404
fi


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

if [ $? -gt 0 ]
then
    Debug "PHP7 Installer: Compile ${APP} error...."
    exit 1
fi

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


#Starting php-fmp
/usr/local/php7/sbin/php-fpm
if [ $? -eq 0 ]
then
    ps -aux|grep php
fi