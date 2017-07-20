#!/usr/bin/env bash
set -o errtrace
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat << EOM
  usage:

  ./$0 [tag]

  tag denotes the combination of the namespace + the image tag

  example:
  $ ./$0 master:1df9571

EOM
  exit 1
}

execute() {
  echo "[*] run: $1"
  $1
}

updatetag() {
  echo "TAG=${NEW_TAG}" > $(dirname $(readlink $0))/../.env
}


main() {
  NEW_TAG=$1
  execute "updatetag"
  execute "systemctl restart app.service"
}

if [ $EUID -lt 1 ]; then
  usage
fi

main "$@"
