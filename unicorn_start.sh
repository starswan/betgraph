#!/bin/bash
#
# $Id$
#
export HOME=~
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
program='unicorn'
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
unicorn="bundle exec unicorn_rails -l 3015"
$unicorn 2>&1 >>$logfile &
echo $! >$pidfile
