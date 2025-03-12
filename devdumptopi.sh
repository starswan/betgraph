#!/bin/bash -x
#
# $Id$
#
# This needs to be re-written using a capistrano task so that it uses the correct
# remote ruby. THis is fudged right now on alice by installing the bundle in the default ruby
localfile=log/betgraph_development.sql.gz
remotefile=pi@pifour:betgraph/shared/log/ssarbicity.sql.gz
#localfile=db/data.yml
#remotefile=alice:html/betgraph/shared/log/data.yml
#date
#if [ -f $localfile.gz ]
#then
#  gunzip -f $localfile.gz
#fi
#ssh pi@pifour 'cd betgraph/current && . ~/.bash_profile && nice gunzip -f log/ssarbicity.sql.gz'
rsync -e ssh -avPp $localfile $remotefile
#nice -20 gzip -3 -f $localfile &
if [ $? == 0 ]
then
#  ssh pi@pifour 'cd betgraph/current && . ~/.bash_profile && nice gzip -3 -f log/ssarbicity.sql'
  ssh pi@pifour 'cd betgraph/current && . ~/.bash_profile && rvm use 3.2.7@bg && RAILS_ENV=pi DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rake db:drop db:create'
  date
# zcat/gzcat is confusing - gunzip -c (stdout) is a portable improvement
  time ssh pi@pifour "cd betgraph/current && . ~/.bash_profile && rvm use 3.2.7@bg && nice gunzip -c log/ssarbicity.sql.gz | RAILS_ENV=pi rails db -p"
fi
#time nice rake db:data:load
#time nice rake db:migrate
