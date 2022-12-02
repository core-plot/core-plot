#!/bin/sh 

uncrustify=`which uncrustify`

file_list=`find ".." -name "*.[mh]" \! -iregex ".*/build/.*" -type f | sed "s| \([^/]\)|:\1|g"`

for file in $file_list
do

file2indent=`echo $file | sed "s|:| |g"`
echo "Indenting file '$file2indent'"
#!/bin/bash
"$uncrustify" -l OC -f "$file2indent" -c "./uncrustify.cfg" -o "./indentoutput.tmp"

# remove spaces before category names to keep Doxygen happy and fix other uncrustify bugs
cat "./indentoutput.tmp" | \
sed "s|in\[|in \[|g" | \
sed "s|>{|> {|g" | \
sed "s|\(@interface .*\) \((.*)\)|\1\2|g" | \
sed "s|\(@implementation .*\) \((.*)\)|\1\2|g" > "$file2indent"

rm "./indentoutput.tmp"

done
