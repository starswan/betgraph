#!/bin/bash
#
# $Id$
#
export HOME=~
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
unicorn='bundle exec unicorn_rails -l 3015'
$unicorn >>log/unicorn.log &
echo $! >tmp/pids/unicorn.pid
