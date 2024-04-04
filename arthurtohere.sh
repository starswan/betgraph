#!/bin/bash -x
#
# $Id$
#
#ssh arthur 'cd github/betgraph && nice rake db:backup'
#ssh arthur 'cd github/betgraph && nice ./unpack_rake_backup.sh'

localfile=log/bfrails_development.sql.gz
remotefile=arthur:github/betgraph/log/bfrails_development.sql.gz
#localfile=db/data.yml
#remotefile=alice:html/bfrails4/shared/log/data.yml
#if [ -f $localfile.gz ]
#then
#  nice gunzip -f $localfile.gz
#fi
date
rsync -e ssh -avPp $remotefile $localfile
#nice -20 gzip -f $localfile &
rake db:drop db:create
date
time nice zcat $localfile | rails db -p
#time nice rake db:data:load
time nice rake db:migrate
