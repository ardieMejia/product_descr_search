#!/bin/bash





processUrl () {





    echo
    echo
    LsingleSite=$(echo $site | awk '{gsub("https://","");gsub("\.","-");gsub("/","-");print $0}')
    singleSite=$(echo $LsingleSite | awk 'BEGIN{FS="?"}{print $1}')
    singleSite=${singleSite:0:100}


    echo "++++++++++++++++++++ "$singleSite" ++++++++++++++++++++"
    echo "ORIGINAL "$site" ORIGINAL"



    w3m -dump $site > ./middle/$singleSite.txt
    sed -i 's/•/./g' ./middle/$singleSite.txt; sed -i 's/□/./g' ./middle/$singleSite.txt; sed -i 's/☆/./g' ./middle/$singleSite.txt
    repooutputpath=./processed/w3m/${singleSite}-output.txt



    raw=$(cat ./middle/$singleSite.txt)









    recordSeparator="[:.!]"


    : '
        product code
        piece
        qty
        add to cart
        add to wishlist
        description

        ----- It should be the first one!!

        ----- EXCLUSION TERMS
         - below
         -

        '




    echo "---------- every ----------" >> $repooutputpath
    echo $raw | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "every") print $0}' >> $repooutputpath





}



someInitialChecks () {


    if [[ hardFile -eq 1 ]]; then
        reponame="mytest"
    fi
}







localOnly=0
hardFile=0 # ---------- harder than localOnly

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
rm -v ./middle/*txt







IFS=","
# _rec1 to _rec6 is urls
# _rec7 is output file name
while read -r site
do
    # ----- we dont need to check for headers
    someInitialChecks
    processUrl
done < ./input/input927.csv
