#!/usr/bin/env bash

# turns off questions
export DEBIAN_FRONTEND=noninteractive

echo '!!SCRIPT - attempting database';


# for file in /vagrant/database/*; do
#     sudo -u postgres psql postgres -f "$file"
# done



# db name
APP_DB_USER=myapp
# db password
APP_DB_PASS=dbpass

# db name
APP_DB_NAME=myapp

# postgresql version
PG_VERSION=9.3

###########################################################
# Changes below this line are probably not necessary
###########################################################
print_db_usage () {
  echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 15432)"
  echo "  Host: localhost"
  echo "  Port: 15432"
  echo "  Database: $APP_DB_NAME"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo ""
  echo "psql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost $APP_DB_NAME"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=postgresql://$APP_DB_USER:$APP_DB_PASS@localhost:15432/$APP_DB_NAME"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost -p 15432 $APP_DB_NAME"
}


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
apt-get update
apt-get -y upgrade

apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

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

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS';

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF

# Tag the provision time:
date > "$PROVISIONED_ON"

echo "Successfully created PostgreSQL dev virtual machine."
echo ""
print_db_usage



### install all sorts of shit
echo '!!SCRIPT - installing php';
sudo apt-get -y install php5-pgsql php5-cli libapache2-mod-php5


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


# ### copy configs
# # copy the hba conf to the linux conf
# if [ ! -f /etc/postgresql/9.1/main/pg_hba-original.conf ];
# then
#     echo '!!SCRIPT - backing up pg_hba.conf';
#     sudo cp -f /etc/postgresql/9.1/main/pg_hba.conf /etc/postgresql/9.1/main/pg_hba-original.conf
# fi
# echo '!!SCRIPT - copying pg_hba.conf';
# sudo cp -f /vagrant/config/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf

# # copy the postgresql conf to the linux conf
# if [ ! -f /etc/postgresql/9.1/main/postgresql-original.conf ];
# then
#     echo '!!SCRIPT - backing up postgresql.conf';
#     sudo cp -f /etc/postgresql/9.1/main/postgresql.conf /etc/postgresql/9.1/main/postgresql-original.conf
# fi
# echo '!!SCRIPT - copying postgresql.conf';
# sudo cp -f /vagrant/config/postgresql.conf /etc/postgresql/9.1/main/postgresql.conf





#install vim
echo '!!SCRIPT - vim';
sudo apt-get install -y vim


# restart all the things
echo '!!SCRIPT - restarting postgres and apache';
sudo service postgresql restart
sudo service apache2 restart



