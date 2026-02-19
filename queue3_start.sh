#!/bin/bash
#
# $Id$
#
export HOME=`echo ~`
source $HOME/.bash_login
dirname=`dirname $0`
cd $dirname
source $RVM_DIR/environments/ruby-3.2.9@bg
bundle check || bundle install
program='queue3'
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
#echo $$ >$pidfile
#exec rake backburner:work 2>&1 >>$logfile
nice rake backburner:work 2>&1 >>$logfile &
echo $! >$pidfile