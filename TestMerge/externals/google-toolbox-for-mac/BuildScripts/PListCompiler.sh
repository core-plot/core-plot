#!/bin/sh
# PlistCompiler.sh

# Copyright 2010 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

# Takes a file (usually with a suffix of .plistsrc) and "compiles it" using
# the gcc preprocessor.
# The best way to use PlistCompiler is to add a custom build rule to your target
# in Xcode with the following settings:
# Process: "Source files with names matching:" "*.plistsrc"
# using: "Custom script:"
# "Path/to/PlistCompiler/relative/to/${SRCROOT}'
# with output files:
# ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${INPUT_FILE_BASE}.plist
# You can control the include paths by setting the 
# GTM_PLIST_COMPILER_INCLUDE_PATHS environment variable to a colon delimited
# path string. It defaults to "."


set -o errexit
set -o nounset

GTM_PLIST_COMPILER_INCLUDE_PATHS=${GTM_PLIST_COMPILER_INCLUDE_PATHS:="."}

if [[ $# -ne 2 && $# -ne 0 ]] ; then
  echo "usage: ${0} INPUT OUTPUT" >&2
  exit 1
fi

if [[ $# -eq 2 ]] ; then
  SCRIPT_INPUT_FILE="${1}"
  SCRIPT_OUTPUT_FILE="${2}"
else
  SCRIPT_INPUT_FILE="${INPUT_FILE_PATH}"
  SCRIPT_OUTPUT_FILE="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${INPUT_FILE_BASE}.plist"
fi

# Split up the passed in include paths
SaveIFS=$IFS
IFS=":"
split_include_paths=""
for a in ${GTM_PLIST_COMPILER_INCLUDE_PATHS};
do
split_include_paths="$split_include_paths -I '$a'"
done
IFS=$SaveIFS

# run gcc and strip out lines starting with # that the preprocessor leaves behind.
eval gcc ${split_include_paths} -E -x c "${SCRIPT_INPUT_FILE}" | sed 's/^#.*//g' > "${SCRIPT_OUTPUT_FILE}"
