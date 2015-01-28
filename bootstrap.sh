#!/usr/bin/env bash

### update apt-get
sudo apt-get update

### install all sorts of shit
echo '!!SCRIPT - install all sorts of shit';
sudo apt-get -y install postgresql postgresql-contrib php5-pgsql php5-cli libapache2-mod-php5


# echo '!!SCRIPT - setting up db';
# sudo -u postgres psql postgres
# \password postgres
# \q
# sudo su postgres
# createdb application 

echo '!!SCRIPT - attempting database';

for file in /vagrant/database/*; do
    sudo -u postgres psql postgres -f "$file"
done


# install apache
echo '!!SCRIPT - Installing apache';
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

# apache2 enable php
echo '!!SCRIPT - a2enmod';
a2enmod php5

### copy configs
# copy the hba conf to the linux conf
if [ ! -f /etc/postgresql/9.1/main/pg_hba-original.conf ];
then
    echo '!!SCRIPT - backing up pg_hba.conf';
    sudo cp -f /etc/postgresql/9.1/main/pg_hba.conf /etc/postgresql/9.1/main/pg_hba-original.conf
fi
echo '!!SCRIPT - copying pg_hba.conf';
sudo cp -f /vagrant/config/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf

# copy the postgresql conf to the linux conf
if [ ! -f /etc/postgresql/9.1/main/postgresql-original.conf ];
then
    echo '!!SCRIPT - backing up postgresql.conf';
    sudo cp -f /etc/postgresql/9.1/main/postgresql.conf /etc/postgresql/9.1/main/postgresql-original.conf
fi
echo '!!SCRIPT - copying postgresql.conf';
sudo cp -f /vagrant/config/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf

# copy in php.ini
if [ ! -f /etc/php5/apache2/php-original.ini ];
then
    echo '!!SCRIPT - backing up php.ini';
    sudo cp -f /etc/php5/apache2/php.ini /etc/php5/apache2/php-original.ini
fi
echo '!!SCRIPT - copying php.ini';
sudo cp -f /vagrant/config/php.ini /etc/php5/apache2/php.ini

# copy in httd.conf
if [ ! -f /etc/apache2/httpd-original.conf ];
then
    echo '!!SCRIPT - backing up httpd.conf';
    sudo cp -f /etc/apache2/httpd.conf /etc/apache2/httpd-original.conf
fi
echo '!!SCRIPT - copying httpd.conf';
sudo cp -f /vagrant/config/httpd.conf /etc/apache2/httpd.conf



#install vim
echo '!!SCRIPT - vim';
sudo apt-get install -y vim


# restart all the things
echo '!!SCRIPT - restarting postgres and apache';
sudo service postgresql restart
sudo service apache2 restart



