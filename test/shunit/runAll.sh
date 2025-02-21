#!/bin/sh

# fundamentals

if [ -z ${PSF_HOME+x} ]; then
  echo "FATAL: you must set the PSF_HOME variable"
  exit 1
fi

if [ ! -f "${PSF_HOME}/posix-scripting-framework.sh" ]; then
  echo "FATAL: file ${PSF_HOME}/posix-scripting-framework.sh does not exist!"
  exit 2
fi

# shellcheck source=SCRIPTDIR/../../posix-scripting-framework.sh
. "${PSF_HOME}/posix-scripting-framework.sh"

if ! shunit2 base.sh ; then
  echo "Fix the framework first!"
fi

echo "Continue..."