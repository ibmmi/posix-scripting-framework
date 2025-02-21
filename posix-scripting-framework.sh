#!/bin/sh

# shellcheck disable=SC3043

# In this library some linter warnings are ignored on purpose
# SC3043 - In POSIX sh, local is undefined. 
# While this is true, most of the shells we use are recognizing the local keyword

init(){
  export PSF_COLOR="${PSF_COLOR:-'NO'}"
  export PSF_DEBUG="${PSF_DEBUG:-'NO'}"
}

log(){
  # params
  # $1 - message, mandatory
  # $2 - log level, optional. Default "I"
  local lvl="${2:-I}"
  local t
  local psfPfx="PSF:"
  t="$(getTime)"
  if [ "${PSF_COLOR}" = "YES" ]; then
    local NC='\033[0m' 				  	# No Color
    local Red='\033[0;31m'
    local Green="\033[0;32m"
    local Yellow="\033[0;33m"
    local Orange="\033[1;35m"
    local Blue="\033[0;34m"
    local Cyan="\033[0;36m"
    # not all terminals supports color
    # if not, do not use them :)
    # shellcheck disable=SC3037
    psfPfx="${Green}PSF:"

    local lvlColor="${Cyan}"
    if [ "${lvl}" = "E" ]; then
      lvlColor="${Red}"
    else
      if [ "${lvl}" = "W" ]; then
        lvlColor="${Orange}"
      else
        if [ "${lvl}" = "D" ]; then
          lvlColor="${Blue}"
        else
          if [ "${lvl}" = "W" ]; then
            lvlColor="${Blue}"
          fi
        fi
      fi
    fi
    # shellcheck disable=SC3037
    echo -e "${Yellow}${t}${lvlColor}${lvl}${Yellow}|${psfPfx}${NC}$1"
  else
    echo "${t}${lvl}|${psfPfx}$1"
  fi
  echo "${t}${lvl}|${psfPfx}$1" >> "${PSF_AUDIT_SSN_DIR}/session.log"
}

logI(){
  log "$1"
}

logW(){
  log "$1" "W"
}

logD(){
  log "$1" "D"
}

logE(){
  log "$1" "E"
}

getTime(){
  if [ "${PSF_MILLIS_AVAILABLE}" = "NO" ] ; then
    date -u +"%H%M%S"
  else
    date -u +"%H%M%S.%3N"
  fi
}

assureDownloadableFile(){
  # params
  # ${1} - Target file directory
  # ${2} - Target file name
  # ${3} - sha256 sum of the file
  # ${4} - origin url

  local lPfx="assureDownloadableFile()-"
  if [ ! -f "${1}/${2}" ]; then
    logI "${lPfx}File \"${1}/${2}\" not present, downloading now..." 

    mkdir -p "${1}" || return 1
    curl -L "${4}" -o "${1}/${2}" || return 2
  fi

  logD "${lPfx}Checking sha256sum for file \"${1}/${2}\" ..."

  echo "${3}" "${1}/${2}"  | sha256sum -c
  local res=$?
  if [ ${res} -ne 0 ]; then
    logE "${lPfx}Checksum for file \"${1}/${2}\" does not match!"
    logD "${lPfx}Expected checksum: ${3}"
    # shellcheck disable=SC2086
    logD "${lPfx}Actual   checksum: $(sha256sum ${1}/${2} | cut -F 1)"
    mv "${1}/${2}" "${1}/${2}.dubious"
    return 3
  fi
}

readSecretFromUser() {
  # code inspired from https://stackoverflow.com/questions/3980668/how-to-get-a-password-from-a-shell-script-without-echoing
  # copied from older repo 
  # https://github.com/SoftwareAG/sag-unattended-installations/blob/9423db39b5180a2e5b28b4ff848722f0d262b7c2/01.scripts/commonFunctions.sh#L266C1-L286C2  
  
  stty -echo
  secret="0"
  local s1 s2
  while [ "${secret}" = "0" ]; do
    printf "Please input %s: " "${1}"
    read -r s1
    printf "\n"
    printf "Please input %s again: " "${1}"
    read -r s2
    printf "\n"
    if [ "${s1}" = "${s2}" ]; then
      secret=${s1}
    else
      echo "Input do not match, retry"
    fi
    unset s1 s2
  done
  stty echo
}

initAuditSession(){
  local lPfx="initAuditSession()-"
  export PSF_AUDIT_BASE_DIR="${PSF_AUDIT_BASE_DIR:-/tmp/PSF_AUDIT}"

  # shellcheck disable=SC2155
  local testMillis="$(date -u +".%3N")"
  local d

  export PSF_MILLIS_AVAILABLE="YES"
  if [ "." = "${testMillis}" ] ; then
    export PSF_MILLIS_AVAILABLE="NO"
    d=$(date -u +"%y%m%dT%H%M%S")
  else
    d=$(date -u +"%y%m%dT%H%M%S.%3N")
  fi

  if [ -z ${PSF_AUDIT_SSN_DIR+x} ]; then
    export PSF_AUDIT_SSN_DIR="${PSF_AUDIT_BASE_DIR}/psf-ssn-${d}"
    mkdir -p "${PSF_AUDIT_SSN_DIR}"
    logI "${lPfx}Session psf-ssn-${d} started"
    logI "${lPfx}Folder ${PSF_AUDIT_SSN_DIR} created"
  else
    mkdir -p "${PSF_AUDIT_SSN_DIR}"
    logI "${lPfx}At datetime ${d} Received existing session directory ${PSF_AUDIT_SSN_DIR}"
  fi
}

init
initAuditSession
