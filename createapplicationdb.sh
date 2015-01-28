#! /bin/sh

for file in /database/*; do
    sudo -u postgres psql postgres -f "$file"
done