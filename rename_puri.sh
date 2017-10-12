#!/bin/bash

IFS=$'\n'
files=$(ls)
file_index=0
for name in `ls  '/home/bobarch/プリパラ☆ミュージックコレクションseason.3[Disc1]'`; do
	rename $files[$file_index] $name
	let file_index++
done
#echo "$file_names"
