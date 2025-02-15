#!/bin/bash
#
# $Id$
#
# clunky native backup - but over in about 90 seconds...
#
source $HOME/.rvm/environments/ruby-3.2.7@bg
rake db:backup
./unpack_rake_backup.sh
