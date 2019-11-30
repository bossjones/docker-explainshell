#!/bin/bash

trap "exit" INT TERM
trap "kill 0" EXIT

mongod --dbpath /data/db2 --bindip 0.0.0.0 &
(cd explainshell && env HOST_IP=0.0.0.0 make serve) &
env EXPLAINSHELL_ENDPOINT=http://localhost:5000 lsp-adapter --trace --glob="*.sh:*.bash:*.zsh" --proxyAddress=0.0.0.0:8080 bash-language-server start &

while sleep 1; do
  if ! pgrep mongod >/dev/null; then
    echo "ERROR mongod died"
    exit 1
  fi
  if ! pgrep make >/dev/null; then
    echo "ERROR make died"
    exit 1
  fi
  if ! pgrep lsp-adapter >/dev/null; then
    echo "ERROR lsp-adapter died"
    exit 1
  fi
done
