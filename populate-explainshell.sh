#!/bin/bash

wait_for_mongo_up() {
  while true; do
    nc -zvv localhost 27017 && return
    sleep 1
  done
}

wait_for_server_up() {
  while true; do
    nc -zvv localhost 5000 && return
    sleep 1
  done
}

mongod --dbpath /data/db2 &
make serve &
wait_for_mongo_up
wait_for_server_up
mongorestore -d explainshell dump/explainshell && mongorestore -d explainshell_tests dump/explainshell
make tests

git clone https://github.com/idank/explainshell-manpages
find explainshell-manpages -name "*.gz" | xargs -n 1000 env PYTHONPATH=. python explainshell/manager.py

# MANUAL SECTIONS
# The standard sections of the manual include:

# 1      User Commands
# 2      System Calls
# 3      C Library Functions
# 4      Devices and Special Files
# 5      File Formats and Conventions
# 6      Games et. al.
# 7      Miscellanea
# 8      System Administration tools and Daemons

# Distributions customize the manual section to their specifics,
# which often include additional sections.

find /usr/share/man/man1 -name "*.gz" | xargs -n 1000 env PYTHONPATH=. python explainshell/manager.py

find /usr/share/man/man8 -name "*.gz" | xargs -n 1000 env PYTHONPATH=. python explainshell/manager.py

jobs -p | xargs kill
