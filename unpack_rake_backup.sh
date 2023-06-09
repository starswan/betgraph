#!/bin/bash
#
# $Id$
tar xf db/db_backup/*/db_backup.tar
rm -f db/db_backup/*/db_backup.tar
mv db_backup/databases/MySQL/*.sql log
gzip -3 -f log/*.sql
rm -rf db/db_backup
rm -rf db_backup

# yaml_db backup - takes N hours (N =~ 6?)
#rm -f log/data.yml.bak
#mv log/data.yml log/data.yml.bak
# The restore uses vast amounts of RAM - so maybe disable for now...
#rake db:data:dump && mv db/data.yml log
