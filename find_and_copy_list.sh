#!/bin/bash

# Find a list of files from a text file, then copy all matches to a directory

cat file_list.txt | while read f; do find . -name "*$f*" -exec cp {} /copy/dir \;; done
