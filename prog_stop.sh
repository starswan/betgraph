#!/bin/bash
#
# $Id$
#
#./run.sh $1 clock clockwork config/clock.rb
export HOME=`echo ~`
#source $HOME/.bash_profile
#source $HOME/.profile
dirname=`dirname $0`
cd $dirname
program=$1
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
pid=`cat $pidfile`
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill $pid
fi
sleep 2
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill $pid
fi
sleep 2
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill -9 $pid
fi
