#!/bin/bash
ulimit -m 1024000
while [ 1 ]; do  rake backburner:work; sleep 10; date; done
