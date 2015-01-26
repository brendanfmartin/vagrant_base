#!/usr/bin/env bash

# update apt-get
sudo apt-get update

#install apache
sudo apt-get -y install postgresql postgresql-contrib php5-pgsql
# copy the conf to the linux conf
cp -f /vagrant/config/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
# start postgres
service postgresql restart

# install apache
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi


# install apache lib to run php
sudo apt-get -y install libapache2-mod-php5
# apache2 enable php
a2enmod php5

sudo apt-get install php5-cli

sudo apt-get install vim

#turn display_errors on in php.ini

#sudo su postgres

#create user application

#/etc/postgresql/9.1/main/postgresql.conf
#listen_addresses = '*'

#cd
#sudo -u postgres psql template1
#ALTER USER postgres with encrypted password 'your_password';

sudo service postgresql restart

createtable application_test