#!/usr/bin/env bash
set -o errtrace
set -euo pipefail
IFS=$'\n\t'

SYSINIT=$(pidof systemd > /dev/null && echo "/etc/systemd" || echo "/etc/init")
INSTALL_DIR="$( cd "${0%/*}/.." && pwd )"

usage() {
  cat << EOM
  usage:

  ./$0 [tag]

  tag denotes the combination of the namespace + the image tag

  example:
  $ ./$0 master:1df9571

EOM
}

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
    sed -r "s|@@PREFIX@@|${INSTALL_DIR}|; s|@@APP@@|cadvisor|g" \
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
  #systemctl daemon-reload
  #for t in ${INSTALL_DIR}/init/*.service; do
  #  systemctl enable $t
  #done
  initctl reload-configuration
  for t in ${INSTALL_DIR}/init/*.conf; do
    service $(basename ${t%.*}) start 
  done
}

writeenv() {
  [[ ! -f "${INSTALL_DIR}/.env" ]] && echo "TAG=$TAG" >> "${INSTALL_DIR}/.env"
  chmod 666 "${INSTALL_DIR}/.env"
}

main() {
  TAG=${1:-master/latest}
  execute "template"
  execute "enableservice"
  execute "writeenv"
  ln -s ${INSTALL_DIR}/bin/update-tag.sh /usr/local/bin/update-tag.sh
}

if [ $EUID -ne 0 ]; then
  echo "execute as root"
  exit 1
fi

main "$@"
