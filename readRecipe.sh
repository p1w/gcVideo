#!/bin/bash

input="./test.recipe"


#read each line of the file
while IFS= read -r line
do

    #split each line on the @
    IFS=\@; read -a fields <<< "$line"

    for x in "${fields[@]}";do


	if [[ $x =~ "x" ]]
	then
	    echo "> [$x]"
	    repeat="${x%%x*}"
	    until [ $repeat -lt 1 ]
	    do
		  echo repeat $repeat
		  let repeat-=1
	    done
	fi



    done

    
done < "$input"
