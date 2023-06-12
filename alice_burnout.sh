#!/bin/bash

# configure route server name in scope or add your regex (.*) to all
SCOPE='.*'
# resource protection limiting number of forks
MAX_FORKS=1000

REGEX_URL='(https?):\/\/[-A-Za-z0-9]+\.[-A-Za-z0-9]{2,6}(\.[-A-Za-z0-9]{2,6})*'
URL="${1}"
LG_URL=$(printf "%s" "${URL}" | sed 's/\/$//')

if [[ -z "${1}" ]]; then
  echo "Missing argument..."
  exit 1
fi

if [[ -n "${2}" ]]; then
  SCOPE="${2}"
fi

function burnout() {
  ROUTE_SERVERS=$(curl -s "${LG_URL}/api/v1/routeservers" 2>/dev/null | sed 's/%$//' | jq -r '.routeservers[].id' 2>/dev/null)

  echo "Starting stress test at $(date) - $(date +%s)."
  while true; do
    FORKS=$(pgrep xargs | wc -l)
    echo "${FORKS} Forks running at $(date) - $(date +%s)"
    curl -Is "${LG_URL}" >/dev/null 2>&1 ||
      echo "LG is unresponsive at $(date) - ${FORKS} running."
    while read -r ROUTE_SERVER; do
      if [[ "${ROUTE_SERVER}" =~ ${SCOPE} ]]; then
        if [[ "${FORKS}" -le "${MAX_FORKS}" ]]; then
          NEIGHBORS=$(curl -s "${LG_URL}/api/v1/routeservers/${ROUTE_SERVER}/neighbors" 2>/dev/null | sed 's/%$//' | jq -r ".neighbors[].id" 2>/dev/null)
          if [[ "${NEIGHBORS}" == "" ]]; then
            NEIGHBORS=$(curl -s "${LG_URL}/api/v1/routeservers/${ROUTE_SERVER}/neighbors" 2>/dev/null | sed 's/%$//' | jq -r ".neighbours[].id" 2>/dev/null)
          fi
          while read -r NEIGHBOR; do
            echo "${LG_URL}/api/v1/routeservers/${ROUTE_SERVER}/neighbors/${NEIGHBOR}/routes" | xargs -I {} curl -s {} -o /dev/null 2>/dev/null &
          done <<<"${NEIGHBORS}"
          FORKS=$(pgrep xargs | wc -l)
          echo "${FORKS} Forks running at $(date) - $(date +%s)"
        else
          FORKS=$(pgrep xargs | wc -l)
        fi
      fi
    done <<<"${ROUTE_SERVERS}"

  done
}

function main() {
  if [[ "${LG_URL}" =~ ${REGEX_URL} ]]; then
    true
  else
    echo "The informed URL looks to have a wrong pattern, please check!"
    exit 1
  fi

  burnout
}

main
