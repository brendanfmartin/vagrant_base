#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive


############################
# database
############################

# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=9.3



PROVISIONED_ON=/etc/vm_provision_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'apt-get update && apt-get upgrade'"
  echo ""
  print_db_usage
  exit
fi

PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]
then
  # Add PG apt repo:
  echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > "$PG_REPO_APT_SOURCE"

  # Add PGDG repo key:
  wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
fi

# Update package list and upgrade all packages
sudo apt-get update
apt-get -y upgrade

sudo apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
service postgresql restart


# Setting up db
echo '!!SCRIPT - creating user and db';
cat << EOF | su - postgres -c psql


EOF

echo '!!SCRIPT - setting up db';
for file in /vagrant/database/*; do
    sudo -u postgres psql -d $APP_DB_NAME postgres -f "$file"
done

echo '!!SCRIPT - granting user access';
cat << EOF | su - postgres -c psql
  GRANT ALL ON DATABASE $APP_DB_NAME TO $APP_DB_USER;
  ALTER user postgres with password 'postgres';
EOF



############################
# php & apache
############################



### install all sorts of shit
echo '!!SCRIPT - installing php';
sudo apt-get -y install php5 php5-pgsql php5-cli libapache2-mod-php5


# install apache
echo '!!SCRIPT - Installing apache';
sudo apt-get install -y apache2
if ! [ -L /var/www ]; then
  sudo rm -rf /var/www
  sudo ln -fs /vagrant/zend /var/www
fi

# apache2 enable php
echo '!!SCRIPT - a2enmod';
a2enmod php5



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



# copy in 001-test.conf
if [ ! -f /etc/apache2/sites-available/001-test-original.conf ];
then
    echo '!!SCRIPT - backing up 001-test.conf';
    sudo cp -f /etc/apache2/sites-available/001-test.conf /etc/apache2/sites-available/001-test-original.conf
fi
echo '!!SCRIPT - copying 001-test.conf';

sudo cp -f /vagrant/config/001-test.conf /etc/apache2/sites-available/001-test.conf
sudo ln -fs /etc/apache2/sites-available/001-test.conf /etc/apache2/sites-enabled/001-test.conf
sudo rm -f /etc/apache2/sites-enabled/000-default.conf 

#enable mod_rewrite
sudo a2enmod rewrite

# restart all the things
echo '!!SCRIPT - restarting postgres and apache';
sudo service apache2 restart


#install vim
echo '!!SCRIPT - vim';
sudo apt-get install -y vim


# install zend
cd /vagrant/zend
php composer.phar install