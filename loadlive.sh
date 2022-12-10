#!/bin/bash -x
#
# $Id$
#
nice rake db:drop
nice rake db:create
file=log/ssarbicity.sql
date
time zcat $file.gz | nice rails db -p
time nice rake db:migrate
