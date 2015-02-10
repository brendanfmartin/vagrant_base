#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive


############################
# database
############################

# Edit the following to change the name of the database user that will be created:
APP_DB_USER=myapp
APP_DB_PASS=dbpass

# Edit the following to change the name of the database that is created (defaults to the user name)
APP_DB_NAME=$APP_DB_USER

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
# apt-get -y upgrade

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

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS';

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;

-- Sequence: person_seq
CREATE SEQUENCE person_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 2
  CACHE 1;
ALTER TABLE person_seq
  OWNER TO $APP_DB_USER;


-- Table: person
CREATE TABLE person
(
  id integer NOT NULL DEFAULT nextval('person_seq'::regclass),
  first_name character varying,
  last_description character varying,
  height float,
  weight float,
  CONSTRAINT person_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE person
  OWNER TO $APP_DB_USER;


INSERT INTO person(first_name, last_description, height, weight)
    VALUES ('Brendan', 'Martin', 70, 200);

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

# restart all the things
echo '!!SCRIPT - restarting postgres and apache';
sudo service apache2 restart


#install vim
echo '!!SCRIPT - vim';
sudo apt-get install -y vim