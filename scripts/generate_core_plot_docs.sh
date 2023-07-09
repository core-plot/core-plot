#!/bin/sh

#  Build the Doxygen documentation for the project

#  Required script parameters:
#   $1: Doxygen .config filename
#   $2: Output folder name
#   $3: Docset filename (defined in the .config file)

#  Use the following to adjust the value of the $DOXYGEN_PATH User-Defined Setting:
#    Binary install location: /Applications/Doxygen.app/Contents/Resources/doxygen
#    Source build install location: /usr/local/bin/doxygen

#  Graphical class diagrams require Graphviz.
#  Graphviz.app is available free online
#  http://www.graphviz.org/Download_macos.php

#  If the config file doesn't exist, run 'doxygen -g "${SOURCE_ROOT}/../documentation/doxygen/$1.config"' to
#  create a default file.

DOXYGEN_FOLDER="${SOURCE_ROOT}/../documentation/doxygen"

if ! [ -f "${DOXYGEN_FOLDER}/$1.config" ]
then
  echo Doxygen config file does not exist
  ${DOXYGEN_PATH} -g "${DOXYGEN_FOLDER}/$1.config"
fi

#  Run Doxygen on the updated config file.
#  Note: Doxygen creates a Makefile that does most of the heavy lifting.
${DOXYGEN_PATH} "${DOXYGEN_FOLDER}/$1.config"

#  make a copy of the html docs
DOCS_FOLDER="${SOURCE_ROOT}/../documentation/html/$2"

rm -Rf "${DOCS_FOLDER}"
mkdir -p "${DOCS_FOLDER}"

cp -R "${SOURCE_ROOT}/$3.docset/html/" "${DOCS_FOLDER}"

rm -Rf "${SOURCE_ROOT}/$3.docset"
rm -f "${DOCS_FOLDER}/Info.plist"
rm -f "${DOCS_FOLDER}/Makefile"
rm -f "${DOCS_FOLDER}/Nodes.xml"
rm -f "${DOCS_FOLDER}/Tokens.xml"

# Fix capitalization for GitHub pages
cd "${DOCS_FOLDER}"

ls _*.* | while read a; do n=$(echo $a | sed -e 's/^_//'); mv "$a" "$n"; done
ls *.html | xargs sed -i '' 's/\"_/\"/g'
ls *.js | xargs sed -i '' 's/\"_/\"/g'
ls *.map | xargs sed -i '' 's/\"$_/\"$/g'

# Remove ".html" from Apple documentation links
findString="\(apple\.com[A-Z0-9/]*/[A-Z0-9_-]*\)\.html"
replaceString="\1"

for filename in *.html; do
    sed -i "" "s#${findString}#${replaceString}#gi" ${filename}
done

exit 0
