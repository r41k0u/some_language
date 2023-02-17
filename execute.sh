#!/bin/sh

echo "Running exe."
cat sample.txt | tr -d '\r\n' > oneline.txt

value=`cat oneline.txt`
echo $value | ./exe
exit 0