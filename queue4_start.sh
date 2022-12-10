#!/bin/bash
#
# $Id$
#
export HOME=`echo ~`
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
program='queue4'
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
#echo $$ >$pidfile
#exec rake backburner:work 2>&1 >>$logfile
rake backburner:work 2>&1 >>$logfile &
echo $! >$pidfile