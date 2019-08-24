#!/bin/bash

input="./test.recipe"
cardNo=1

interval () {
    #bizare coincidence but passing argument 1m@300@200
    #splits into 3 arguments $1,$2,$3
    len=$1
    power=$2
    cadence=$3
    #remove repeat from end of cadence
    cadence="${cadence%r*}"
}

#read each line of the file
while IFS= read -r line
do
    echo ">>>>>>>>>$line"
    #split each line on the @
    IFS=\@; read -a fields <<< "$line"
   
    #set repeat to 1
    let repeat=1

    #does the line contain a repeat
    if [[ $line =~ "x" ]]
    then
	#get the number of repeats
	let repeat="${line%%x*}"
	#remove the repeat from the start of the line
	line="${line#*x}"
    fi


    #get len,power,cad
    interval $line

    #save len, pow, cad to new vars cos if there is a recovry they get overwritten by calling interval. 
    intLen=$len
    intPow=$power
    intCad=$cadence
    #does the line contain a recovery interval
    if [[ $line =~ "r" ]]
    then
	let rec=1
	recovery="${line#*r}"
        interval $recovery
	recLen=$len
	recPow=$power
	recCad=$cadence
    else
	let rec=0
    fi

    #now we have got len,pow,cad and any repeats and recovery output pics and create the ffmpeg file
    until [ $repeat -lt 1 ]
    do
	card="./cards/$cardNo.jpg"
	let cardNo+=1

	convert -size 1000x200 xc:blue -gravity center -weight 700 -pointsize 48 -fill white -annotate 0 "$intLen sec at $intPow W - $intCad rpm" $card
	#write out to concat demuxer list
	echo -e "file '$card' \nduration $intLen" >> imgList

	if [ $rec = 1 ]
	then
	    card="./cards/$cardNo.jpg"
            let cardNo+=1
	    	
            convert -size 1000x200 xc:blue -gravity center -weight 700 -pointsize 48 -fill white -annotate 0 "$recLen sec at $recPow W - $recCad rpm" $card
	    echo -e "file '$card' \nduration $recLen"	>> imgList
	fi
	let repeat-=1
    done
    
done < "$input"
#write out last card to concat demuxer list without a duration its a bug in ffmpeg
echo -e "file '$card'"	>> imgList

#create video
ffmpeg -f concat -safe 0 -i imgList -vsync vfr -pix_fmt yuv420p output.mp4
