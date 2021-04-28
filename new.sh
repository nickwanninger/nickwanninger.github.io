#!/bin/bash


NAME="$(date +'%Y-%m-%d')-$(echo $@ | tr '[:upper:]' '[:lower:]' | tr -cd '[a-zA-Z0-9]._- ' | tr ' ' '-' )"


FILE="_posts/$NAME.md"
rm -f $FILE
touch $FILE


echo "---" >> $FILE
echo "layout: post" >> $FILE
echo "title: $@" >> $FILE
echo "---" >> $FILE



echo "Created the file:"
cat $FILE
