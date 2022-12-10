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

pid=`cat $pidfile`
kill $pid
sleep 5
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill $pid
fi
sleep 5
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill -9 $pid
fi
