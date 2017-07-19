#!/usr/bin/env bash
set -o errtrace
set -euo pipefail
IFS=$'\n\t'

SYSINIT=/etc/init/
INSTALL_DIR="$( cd "${0%/*}/.." && pwd )"

trap_err() {
  echo "[!] ${0}: an error occured"
  exit 1
}
trap 'trap_err ${$?}' ERR

execute() {
  echo "[*] running: $1"
  $1
}

template() {
  for t in ${INSTALL_DIR}/init/*.template; do
    sed -r "s|@@ASPERA@@|${INSTALL_DIR}|" \
      "${t}" > "${t%.*}"

    if [ ! -f "${SYSINIT}/$(basename ${t%.*})" ]; then
      ln -s "${INSTALL_DIR}/init/$(basename ${t%.*})" \
        "${SYSINIT}/$(basename ${t%.*})"
    else
      echo "Service files exist. Moving on."
    fi
  done
}

enableservice() {
  systemctl daemon-reload
  for t in ${INSTALL_DIR}/init/*.service; do
    systemctl enable $t
  done
}

main() {
  execute "template"
  execute "enableservices"
  ln -s ${INSTALL_DIR}/bin/update-tag.sh /usr/local/bin/update-tag.sh
}

if [ $EUID -ne 0 ]; then
  echo "execute as root"
  exit 1
fi

main
