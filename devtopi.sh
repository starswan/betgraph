#!/usr/bin/env bash
nice rake db:backup
nice ./unpack_rake_backup.sh
./devdumptopi.sh
