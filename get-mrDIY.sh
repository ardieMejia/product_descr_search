#!/bin/bash





processUrl () {


    LsingleSite=$(echo $site | awk '{gsub("https://","");gsub("\.","-");gsub("/","-");print $0}')
    singleSite=$(echo $LsingleSite | awk 'BEGIN{FS="?"}{print $1}')
    singleSite=${singleSite:0:100}

    echo "++++++++++++++++++++ "$singleSite" ++++++++++++++++++++"

    w3m -dump $site > ./middle/$singleSite.txt
    sed -i 's/•/./g' ./middle/$singleSite.txt; sed -i 's/□/./g' ./middle/$singleSite.txt; sed -i 's/☆/./g' ./middle/$singleSite.txt
    descriptionOutputPath=./processed/w3m/${singleSite}-output.txt

    raw=$(cat ./middle/$singleSite.txt)







    echo "---------- description ----------" >> $descriptionOutputPath
    termsArray=("car" "&&" "steering" "&&" "wheel")
    length=${#termsArray[@]}

    for (( i=0; $i < $length; i=$((i+2)) )){
            if [[ $i -eq 0 ]]; then
                termsString='tolower($0) ~ "'${termsArray[0]}'"'
            else
                termsString+=' '${termsArray[$((i - 1))]}' '
                termsString+=' tolower($0) ~ "'${termsArray[$i]}'" '
            fi
        }

    stringBuilder='BEGIN{RS="'$recordSeparator'"} { if( '$termsString' ) print $0} '
    # ========== reading from source file, makes string-building not clash with managing the outer ''
    echo $stringBuilder > ./docs/awkSource.txt
    echo $raw | awk '{print tolower($0)} ' | awk  -f ./docs/awkSource.txt > $descriptionOutputPath

}


localTest () {

    raw="asdasd car steering adasd wheel "
    termsArray=("car" "steering" "wheel")

    echo "---------- description ----------" >> $descriptionOutputPath

    num=1
    for i in ${termsArray[@]}
    do
        if [[ $num -eq 1 ]]; then
            termsString='tolower($0) ~ "'${termsArray[0]}'"'
        else
            termsString+=' && tolower($0) ~ "'$i'" '
        fi
        num=$((num+1))
    done
    echo $termsString

    stringBuilder='BEGIN{RS="'$recordSeparator'"} { if( '$termsString' ) print $0} '
    # ========== reading from source file, makes string-building not clash with managing the outer ''
    echo $stringBuilder > ./docs/awkSource.txt
    echo $raw | awk '{print tolower($0)} ' | awk  -f ./docs/awkSource.txt > $descriptionOutputPath

}








# ---------- this syntax will not work for words
# recordSeparator="[:.!]"





: '
        product code
        piece
        qty
        add to cart
        add to wishlist
        description

        ----- It maybe the first one!!

        ----- EXCLUSION TERMS
         - below
         -
========== product description ==========
         record separator for product description:
          - description
          - shipping (this helps exclude from shiping price)
          - double next line
          -

          requirements:
           - choose the longest paragraph after all filters




after that, must contain keywords, like car and steering, and (preferably searched through google)
and THEN! only search for longer ones


        '



someInitialChecks () {


    if [[ localOnly -eq 1 ]]; then
        descriptionOutputPath=./processed/filter-test-output.txt
    fi
}




localOnly=0
recordSeparator="description|\n"



if [[ ! -d middle ]];then
    mkdir ./middle
fi
if [[ ! -d repoOutput ]];then
    mkdir ./repoOutput
fi
if [[ ! -d tmp ]];then
    mkdir ./tmp
fi

# ===== clean some files
rm -v ./middle/*txt ./processed/w3m/*






# ---------- remove duplicates
cat -n ./input/input.csv | sort -uk2 | sort -nk1  | \
    cut -f2- > ./input/input-cleaned.csv

if [[ $localOnly -eq 1 ]]; then
    someInitialChecks
    localTest
else
    IFS=","
    # _rec1 to _rec6 is urls
    # _rec7 is output file name
    while read -r site
    do
        # ----- we dont need to check for headers
        processUrl
    done < ./input/input-cleaned.csv
fi
