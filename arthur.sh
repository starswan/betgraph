#!/bin/bash
#
# $Id$
#
export HOME=~
source $HOME/.bash_profile
dirname=`dirname $0`
cd $dirname
case $1 in
   start)
      #echo $$ >tmp/pids/unicorn.pid
      #unicorn=`rails r unicorn_launch.rb trains`
      unicorn='bundle exec unicorn_rails -l 3015'
      $unicorn >>log/unicorn.log &
      echo $! >tmp/pids/unicorn.pid
      #echo $$ >tmp/pids/unicorn.pid
      #unicorn=`exec unicorn_rails -l 3120`
      #$unicorn >>log/unicorn.log
      ;;
   stop)
      pid=`cat tmp/pids/unicorn.pid`
      kill $pid
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
      ;;
   *)
      echo "Usage unicorn.sh {start|stop} <root dir>" ;;
esac
exit 0
