#!/bin/bash
#
# $Id$
#
#./run.sh $1 clock clockwork config/clock.rb
source /home/stephen/.rvm/environments/ruby-2.7.6@betgraph
bundle install
export HOME=`echo ~`
source $HOME/.bash_login
dirname=`dirname $0`
cd $dirname
program='clock'
pidfile="tmp/pids/$program.pid"
logfile="log/$program.log"
case $1 in
   start)
      exec clockwork config/clock.rb >>$logfile &
      echo $! >$pidfile
      ;;
   stop)
      pid=`cat $pidfile`
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
      ;;
   *)
      echo "Usage clock.sh {start|stop} <program> <args>" ;;
esac
exit 0