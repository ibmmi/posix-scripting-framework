#!/bin/sh

# shellcheck disable=SC3043

# home variable must be set!
testFramework(){
  local psfh
  psfh=${PSF_HOME:-"not set"}
  assertNotSame "PSF_HOME variable not set!" "${psfh}" "not set"

  if [ ! -f "${PSF_HOME}/posix-scripting-framework.sh" ]; then
    echo "FATAL: file ${PSF_HOME}/posix-scripting-framework.sh does not exist!"
    exit 2
  fi
  # shellcheck source=SCRIPTDIR/../../posix-scripting-framework.sh
  . "${PSF_HOME}/posix-scripting-framework.sh"
}

# logI function must exist
testLogI1(){
  local result=0
  local temp
  temp=$(command -V "logI" 2>/dev/null | grep function) || result=1
  assertEquals "logI function not sourced!" 0 "${result}"
  assertEquals "${temp}" "logI is a function"
  local m
  m="$(logI 'testLogI1')"
  assertContains "Logged line does not contain the message!" "$m" 'testLogI1'
  assertNotSame "Logged line should not be exactly the message" "$m" 'testLogI1'
  local oColor="${PSF_COLOR:-none}"
  export PSF_COLOR=NO
  log "Message, no color -> default level"
  logI "Message, no color -> I level"
  logW "Message, no color -> W level"
  logD "Message, no color -> D level"
  logE "Message, no color -> E level"
  export PSF_COLOR=YES
  log "Message, color -> default level"
  logI "Message, color -> I level"
  logW "Message, color -> W level"
  logD "Message, color -> D level"
  logE "Message, color -> E level"
  if [ "${oColor}" = "none" ]; then
    unset PSF_COLOR
  else
    export PSF_COLOR="${oColor}"
  fi
}

testGetTime(){
  local t
  t=$(getTime)
  assertNotSame "" "${t}"
}
