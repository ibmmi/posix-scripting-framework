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

# Download some file from internet
testAssureDownloadableFile(){
  t=$(getTime)
  assureDownloadableFile \
    "/tmp/a${t}" \
    "README_test.md" \
    "394ac56640b962d8a9384a6d3302527cf638f4aac6d76045cfdfdef2857f4829" \
    "https://raw.githubusercontent.com/ibmmi/posix-scripting-framework/2386c4cbd47d4c3bb46c7d128d2a690576291fc0/README.md"
  local result=$?
  assertEquals 0 ${result}
}
