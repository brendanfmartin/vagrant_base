-- Create the database user:
CREATE USER admin WITH PASSWORD 'password';

-- Create the database:
CREATE DATABASE 'database' WITH OWNER=admin
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;