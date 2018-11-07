#!/bin/bash
#--------------------------------
# Function: install nginx for Ubuntu
# Update:   2018-11-07
# Author:   kirinlabs
#--------------------------------

APP=nginx-1.15.6.tar.gz
DIR=nginx-1.15.6

DOWNPATH="/root/download"
[ ! -d $DOWNPATH ]&&{
	mkdir $DOWNPATH
}

#Print debug information
function Debug(){
    echo ""
    echo -e "\033[37m[$(date)]\033[32m ::::::::::>>>>>-----------------<<<<<::::::::::\033[0m"
    echo -e "\033[37m[$(date)]\033[31m "$1"\033[0m"
    echo ""
}

#Installing dependencies
apt-get install -y gcc autoconf automake libtool cmake
apt-get install -y libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev

ln -s /usr/lib/gcc /usr/lib/cc

#Creating user and group
#useradd -s /sbin/nologin -M www
groupadd www
useradd -g www www
usermod -s /sbin/nologin www

#Download
cd $DOWNPATH
[ ! -f ${DOWNPATH}/${APP} ]&&{
    Debug "Starting download nginx..."
    wget http://nginx.org/download/${APP}
}

if [ $? -gt 1 ]
then
    Debug "Nginx Installer: download ${APP} error..."
    exit 404
fi

#Starting install nginx
[ ! -d ${DOWNPATH}/${DIR} ]&&{
    tar -zxvf ${APP}
}

if [ $? -gt 1 ]
then
    Debug "Nginx Installer: tar ${APP} error..."
    exit 405
fi

cd ${DOWNPATH}/${DIR}

#Compile nginx
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_stub_status_module

#make
make && make install

#Starting Nginx
/usr/local/nginx/sbin/nginx

#Show nginx status
ps -aux|grep nginx
