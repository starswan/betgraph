#!/bin/bash
#
# $Id$
#
export HOME=`echo ~`
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
source /home/stephen/.rvm/environments/ruby-2.7.8@bg
bundle check || bundle install
program='queue2'
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
#echo $$ >$pidfile
#exec rake backburner:work 2>&1 >>$logfile
rake backburner:work 2>&1 >>$logfile &
echo $! >$pidfile
