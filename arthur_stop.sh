#!/bin/bash
#
# $Id$
#
export HOME=~
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
pid=`cat tmp/pids/unicorn.pid`
kill $pid
sleep 2
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill $pid
fi
running=`ps hp $pid | wc -l`
if [ $running == "1" ]
then
    kill -9 $pid
fi