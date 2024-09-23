#!/bin/bash
#
# $Id$
#
localfile=log/betgraph_development.sql
remotefile=alice:html/betgraph/shared/log/starswan_betgraph.sql
#localfile=db/data.yml
#remotefile=alice:html/bfrails4/shared/log/data.yml
#if [ -f $localfile.gz ]
#then
#  nice gunzip -vf $localfile.gz 
#fi
date
rsync -e ssh -avp --progress $remotefile.gz $localfile.gz
if [ $? == 0 ]
then
  #nice -20 gzip -3 -f $localfile &
  DISABLE_DATABASE_ENVIRONMENT_CHECK=1 nice rake db:drop
  rake db:create
  date
  #time nice rails db -p <$localfile
  time nice gunzip -c $localfile.gz | rails db -p
  date
  #time nice rake db:data:load
  time nice rake db:migrate
  date
fi