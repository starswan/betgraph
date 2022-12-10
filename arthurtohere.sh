#!/bin/bash -x
#
# $Id$
#
localfile=log/ssarbicity.sql
remotefile=arthur2:starswan.git/projects/bfrails4/log/bfrails_development.sql
#localfile=db/data.yml
#remotefile=alice:html/bfrails4/shared/log/data.yml
if [ -f $localfile.gz ]
then
  nice gunzip -f $localfile.gz 
fi
date
nice rsync -e ssh -avPpz $remotefile $localfile 
nice -20 gzip -f $localfile &
nice rake db:drop
nice rake db:create
date
time nice rails db -p <$localfile
#time nice rake db:data:load
time nice rake db:migrate
