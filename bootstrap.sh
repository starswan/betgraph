#!/bin/bash
sudo apt-get install curl gnupg2
#gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
sudo apt-get install -y libmysqlclient-dev libxslt1-dev libxml2-dev mysql-server beanstalkd nodejs g++ autoconf bison libffi-dev libgdbm-dev libncurses-dev libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 libgmp-dev libreadline-dev libssl-dev gawk
. ~/.bash_profile
rvm install 2.7.6
rvm use 2.7.6
rvm gemset create betfair
rvm alias create betfair 2.7.6@betfair
rvm use betfair
gem install bundler -v1.17.3
bundle
