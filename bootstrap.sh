#!/usr/bin/env bash

vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostmanager

### update apt-get
sudo apt-get update

### install all sorts of shit
echo 'SCRIPT - install all sorts of shit';
sudo apt-get -y install postgresql postgresql-contrib php5-pgsql php5-cli libapache2-mod-php5



# echo 'SCRIPT - logging in';
# sudo -u postgres psql postgres
# \password postgres
# \q
# sudo su postgres
# createdb application 


# install apache
echo 'Installing apache';
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

# apache2 enable php
echo 'a2enmod';
a2enmod php5

### copy configs
# copy the hba conf to the linux conf
echo 'SCRIPT - copying pg_hba.conf';
sudo cp -f /etc/postgresql/9.1/main/pg_hba.conf /etc/postgresql/9.1/main/pg_hba-original.conf
sudo cp -f /vagrant/config/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf

# copy the postgresql conf to the linux conf
echo 'SCRIPT - copying postgresql.conf';
sudo cp -f /etc/postgresql/9.1/main/postgresql.conf /etc/postgresql/9.1/main/postgresql-original.conf
sudo cp -f /vagrant/config/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf

# copy in php.ini
echo 'SCRIPT - copying php.ini';
sudo cp -f /etc/php5/apache2/php.ini /etc/php5/apache2/php-original.ini
sudo cp -f /vagrant/config/php.ini /etc/php5/apache2/php.ini

# copy in httd.conf
echo 'SCRIPT - copying httpd.conf';
sudo cp -f /vagrant/config/httpd.conf /etc/apache2/httpd-original.conf
sudo cp -f /vagrant/config/httpd.conf /etc/apache2/httpd.conf



#install vim
echo 'SCRIPT - vim';
sudo apt-get install vim


# restart all the things
echo 'SCRIPT - restarting postgres and apache';
sudo service postgresql restart
sudo service apache2 restart



