#!/bin/bash
#--------------------------------------------------------
# Function: install mysql5.7.24 for centos7
# Update:   2018-11-07
# Author:   kirinlabs
#--------------------------------------------------------

APP=mysql-5.7.24.tar.gz
DIR=mysql-5.7.24

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


#Dwonloading boost-1.59.0
[ ! -f ${DOWNPATH}/boost_1_59_0.tar.gz ]&&{
    wget --no-check-certificate http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
}
if [ $? -gt 1 ]
then
	Debug "Mysql Installer: downloading boost_1_59_0.tar.gz error...."
    exit 404
fi


#Downloading mysql-5.7.20
[ ! -f ${DOWNPATH}/${APP} ]&&{
    wget https://dev.mysql.com/get/Downloads/MySQL-5.7/${APP}
}
if [ $? -gt 1 ]
then
	Debug "Mysql Installer: downloading ${APP} error...."
    exit 404
fi


#Creating user and group
groupadd mysql
useradd -g mysql mysql
usermod -s /sbin/nologin mysql


#Creating basedir for mysql
mkdir /usr/local/mysql
mkdir /usr/local/mysql/data


#Installing dependencies
yum install -y gcc gcc-c++ autoconf automake cmake make
yum install -y zlib zlib-devel ncurses ncurses-devel bison git


cd $DOWNPATH

[ ! -f ${DOWNPATH}/boost_1_59_0.tar.gz ]&&{
	Debug "Mysql Installer: file boost_1_59_0.tar.gz is not exists..."
    exit 404
}

[ ! -f ${DOWNPATH}/${APP} ]&&{
	Debug "Mysql Installer: file ${APP} is not exists..."
    exit 404
}

[ ! -d $DOWNPATH/boost_1_59_0 ]&&{
    tar -zxvf boost_1_59_0.tar.gz
    cp -Rf boost_1_59_0 /usr/local/mysql/mysql_boost
}
if [ $? -gt 1 ]
then
	Debug "Mysql Installer: copy /root/download/boost_1_59_0  to /usr/local/mysql/mysql_boost error...."
    exit 403
fi

[ ! -d $DOWNPATH/${DIR} ]&&{
    tar -zxvf ${APP}
}


#Starting install mysql
cd ${DOWNPATH}/${DIR} && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=/usr/local/mysql/mysql_boost \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DENABLE_DOWNLOADS=1

if [ $? -gt 0 ]
then
	Debug "Mysql Installer: cmake mysql error...."
    exit 401
fi


#Make && make install
make && make install
make clean


#Modify
chown -Rf mysql:mysql /usr/local/mysql


#Initialize
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data &>~/.mysql_passwd
if [ $? -gt 0 ]
then
	Debug "Mysql Installer: initialize mysql error...."
    exit 401
fi

rm -rf /etc/my.cnf


#Startup script
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld


#Boot
chkconfig mysqld on && chkconfig --list mysqld


#Start serivice
/usr/local/mysql/bin/mysqld_safe --user=mysql &
if [ $? -gt 0 ]
then
	Debug "Mysql Installer: run mysql error...."
    exit 400
fi

Debug "[$(date)] Mysql Installer: mysql already running..."


#Read password (file:/root/.mysql_passwd)
PASSWORD=$(tail -1 ~/.mysql_passwd|awk '{print $NF}')


#Print initial password
Debug "[$(date)] Mysql Installer: Mysql initial password is "$PASSWORD
