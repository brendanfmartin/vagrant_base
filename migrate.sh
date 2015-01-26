#!/bin/bash
echo 'Opening a tunnel (10101 => 3306) for 60 seconds or until done, whichever is longer...'
ssh -f USER@REMOTE.HOST -L10101:localhost:3306 sleep 60 

echo 'Dumping db via tunnel to your home directory...'
mysqldump -u REMOTEDBUSER -pYOURREMOTEDBPASSWORD -P10101 -h tunnel $1 > ~/$1.sql
rm ~/temp.sql 2>/dev/null

echo "CREATE DATABASE IF NOT EXISTS $1;" > ~/temp.sql

echo 'Creating database if not exists...'
mysql -u LOCALDBUSER -pYOURLOCALDBPASSWORD < ~/temp.sql

echo 'Importing that file into mysql...'
mysql -u LOCALDBUSER -pYOURLOCALDBPASSWORD $1 < ~/$1.sql

echo 'Removing files...'
rm ~/$1.sql

#rm ~/temp.sql
echo 'Done.'