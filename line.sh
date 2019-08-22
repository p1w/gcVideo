#!/bin/bash

line="1m@200@90"

IFS=\@; read -a fields <<< "$line"

for x in "${fields[@]}";do
    echo "> [$x]"
done
