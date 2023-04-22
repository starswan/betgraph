#!/bin/bash -x
#
# $Id$
#
localfile=log/bfrails_development.sql
remotefile=arthur:starswan.git/projects/betgraph/log/bfrails_development.sql
#localfile=db/data.yml
#remotefile=alice:html/bfrails4/shared/log/data.yml
#if [ -f $localfile.gz ]
#then
#  nice gunzip -f $localfile.gz
#fi
date
nice rsync -e ssh -avPp $remotefile.gz $localfile.gz
#nice -20 gzip -f $localfile &
nice rake db:drop
nice rake db:create
date
time nice gunzip -c $localfile.gz | rails db -p
#time nice rake db:data:load
time nice rake db:migrate
