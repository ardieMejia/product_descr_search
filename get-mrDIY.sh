#!/bin/bash





loop_through_URLs () {
    for i in ${urlList[@]}
    do




        echo
        echo
        reponame=$(echo $i | awk '{gsub("https://","");gsub("\.","-");gsub("/","-");print $0}')
        echo "++++++++++++++++++++ "$reponame" ++++++++++++++++++++"


        if [[ "$answer" == "w" ]];then
            w3m -dump $i > ./repoFiles/$reponame.txt
            sed -i 's/•/./g' ./repoFiles/$reponame.txt; sed -i 's/□/./g' ./repoFiles/$reponame.txt; sed -i 's/☆/./g' ./repoFiles/$reponame.txt
            repooutputpath=./repoOutput/w3m/${reponame}-output.txt
        elif [[ "$answer" == "c" ]]; then
            curl -Lk $i > ./repoFiles/$reponame.txt
            # ===== delete between tags <> and between curlies {} and more than paired # AND %
            sed -i 's/<[^>]*>//g; /^$/d; s/{[^}]*}//g' ./repoFiles/$reponame.txt

            # ===== if a line has both more than 3 ';' , then its most likely css, need to filter that one out
            cp ./repoFiles/$reponame.txt ./tmp/tmp1.txt
            awk '{ num=split($0, a, ";"); if(num < 3) print $0; }' ./tmp/tmp1.txt > ./repoFiles/$reponame.txt
            # ===== if a line has both more than 3 '#' , then its most likely css, need to filter that one out
            cp ./repoFiles/$reponame.txt ./tmp/tmp1.txt
            awk '{ num=split($0, a, "#"); if(num < 3) print $0; }' ./tmp/tmp1.txt > ./repoFiles/$reponame.txt
            repooutputpath=./repoOutput/curl/${reponame}-output.txt

        fi




        clean=$(cat ./repoFiles/$reponame.txt)

        output=$clean

        # ===== QUESTIONS_TO_SELF: there must be a way to check numbers paired with percentage. Any chance of % with no numbers?
        # ===== QUESTIONS_TO_SELF: do orders of search terms matter? Should we exclude some? (Eg: include "commission,every,%" but exclude "commission,%,every")

        # ----- for now our code uses only dots(.) as record separator. Mayben we expand using variables
        # ----- note the Record Separator can be expanded, as we decide to "zoom in" or "zoom out" on search result
        # Eg: ========== awkString='BEGIN{RS="to|[:.]"}{print $0}'









        recordSeparator="[:.!]"

        # ---------- Parent tree (mostly)
        # ---------- Parent tree terms must exclude subtree terms (Eg: "every" is a subtree to this, so 'non-recurring' must exclude "every")
        # ------------------------------ NON-RECURRING ------------------------------
        echo "---------- non-recurring ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if (tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) !~ "every" \
&& tolower($0) !~ "flat" && tolower($0) !~ "first purchase" && tolower($0) !~ "fixed" && tolower($0) !~ "per" \
&& tolower($0) !~ "order" && tolower($0) !~ "refer" && tolower($0) !~ "recurring" \
) print $0}' >> $repooutputpath

        # ------------------------------ EVERY ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- every ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "every") print $0}' >> $repooutputpath


        # ------------------------------ FLAT ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- flat ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "flat") print $0}' >> $repooutputpath


        # ------------------------------FIRST PURCHASE ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- first purchase ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "first purchase") print $0}' >> $repooutputpath


        # ------------------------------ FIXED ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- fixed ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "fixed") print $0}' >> $repooutputpath


        # ------------------------------ PER (NOT PERIOD) ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- per (NOT period) ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "per") print $0}' >> $repooutputpath


        # ------------------------------ ONCE OFF ------------------------------
        # ---------- dot-separation + case-insensitive search + "commission" && "%" && "flat"
        echo "---------- once off ----------" >> $repooutputpath
        # echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "per") print $0}'


        # ------------------------------ COMMISSION ORDER ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- commission order ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "order") print $0}' >> $repooutputpath


        # ------------------------------ COMMISSION REFERRAL ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- commission referral ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "refer") print $0}' >> $repooutputpath


        # ------------------------------ COMMISSION PURCHASE ------------------------------
        # ---------- subtree (to non-recurring)
        echo "---------- commission purchase ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "purchase") print $0}' >> $repooutputpath


        # ------------------------------ COMMISSION SALE ------------------------------
        # -------------------- has unique "affiliate", so this might change
        # ---------- subtree (to non-recurring)
        echo "---------- commission sale ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "sale") print $0}' >> $repooutputpath


        # ------------------------------ RECURRING ------------------------------
        # ---------- subtree (to non-recurring)
        # ---------- parent (to others below)
        echo "---------- recurring ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) !~ "monthly" && tolower($0) !~ "sales" ) \
{ num=split($0, a, "%"); if(num < 3) print $0 } \
}' >> $repooutputpath
        # echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "%") num=split($0, a, "%"); if(num > 2) print $0;}'


        # ------------------------------ RECURRING MONTHLY ------------------------------
        # ---------- subtree (to recurring)
        echo "---------- recurring monthly ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) ~ "monthly" \
) print $0}' >> $repooutputpath


        # ------------------------------ SALES ------------------------------
        # ---------- subtree (to recurring)
        echo "---------- sales ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) ~ "sale" \
) print $0}' >> $repooutputpath


        # ------------------------------ REVENUE ------------------------------
        # ---------- (unique)
        echo "---------- revenue ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "revenue" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}' >> $repooutputpath


        # ------------------------------ FEES ------------------------------
        # ---------- (unique)
        echo "---------- fees ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "fee" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}' >> $repooutputpath


        # ------------------------------ INITIAL + RECURRING ------------------------------
        # ---------- (unique)
        # ----- may include additional condition like "sales"
        echo "---------- initial + recurring ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "initial" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}' >> $repooutputpath


        # ------------------------------ SALES + RENEWALS ------------------------------
        # ---------- (unique)
        echo "---------- sales + renewals ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "sale" && tolower($0) ~ "%" && tolower($0) ~ "renewal" \
) print $0}' >> $repooutputpath


        # ------------------------------ LIFETIME ------------------------------
        # ---------- (assume unique)
        echo "---------- lifetime ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "lifetime" && tolower($0) ~ "%" \
) print $0}' >> $repooutputpath


        # ------------------------------ MULTI COMMISSION ------------------------------
        # ---------- subtree (to recurring) (we exclude multi-% in 'recurring')
        echo "---------- multi commission ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "%") { num=split($0, a, "%"); if(num > 2) print $0;} }' >> $repooutputpath


        # ------------------------------ COOKIES ------------------------------
        # ---------- (unique)
        echo "---------- cookies ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "cookie" && tolower($0) ~ "[0-9]") print $0; }' >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "link" && tolower($0) ~ "tracking") print $0; }' >> $repooutputpath


        # ------------------------------ PAYMENT METHOD ------------------------------
        # ---------- (unique & several combinations)
        echo "---------- payment method ----------" >> $repooutputpath
        paymentm=("paypal" "credit" "bank transfer" "wire transfer" "payoneer" "wise transfer" "payone" "cheque" "check" "bitcoin")
        for i in ${paymentm[@]}
        do
            echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "pay" && tolower($0) ~ "'$i'") print $0; }' >> $repooutputpath
            echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "paid" && tolower($0) ~ "'$i'") print $0; }' >> $repooutputpath
        done



        # ------------------------------ MONTHLY PAYOUT / MINIMUM PAYOUT------------------------------
        # ---------- (unique)
        echo "---------- payout ----------" >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "monthly" && tolower($0) ~ "payout") print $0; }' >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "minimum" && tolower($0) ~ "payout") print $0; }' >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "monthly" && tolower($0) ~ "withdrawal") print $0; }' >> $repooutputpath
        echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "minimum" && tolower($0) ~ "withdrawal") print $0; }' >> $repooutputpath


        # ----- here
    done

}



check_tools () {
    if [[ localOnly -eq 0 ]]; then



        # echo $reponame | awk '{ sub("://", "-");gsub("\.","-");gsub("/","-"); print }'

        ##-->> Trafilature is used to clean and process the html page to plain text.
        #
        read -n 1 -p "trafilatura (enter t) or justext (enter j) or w3m (enter w) or curl (enter c)" answer
        if [[ "$answer" == "t" ]]; then
            trafilatura -u https://$domain >$PWD/repoFiles/$reponame.txt
        elif [[ "$answer" == "j" ]]; then
            echo "You dont have trafilatura. Using justext"
            # we activate python virtual environment then we quit, very quick, as this is only for result
            source env/bin/activate
            python -m justext -s English -o ./repoFiles/$reponame.txt $i
            deactivate
        elif [[ "$answer" == "w" ]]; then
            if [[ ! -d repoOutput/w3m ]];then
                mkdir ./repoOutput/w3m
            fi
            rm -v ./repoOutput/w3m/*txt
            echo "=============================="
            echo "You dont have trafilatura. Now using w3m"
        elif [[ "$answer" == "c" ]]; then
            if [[ ! -d repoOutput/curl ]];then
                mkdir ./repoOutput/curl
            fi
            rm -v ./repoOutput/curl/*txt
            echo "=============================="
            echo "No fancy parsing tool. Now using curl command"
        else
            echo "invalid choice"
            exit
        fi
    fi

    if [[ hardFile -eq 1 ]]; then
        reponame="mytest"
    fi
}







localOnly=0
hardFile=0 # ---------- harder than localOnly

if [[ ! -d repoFiles ]];then
    mkdir ./repoFiles
fi
if [[ ! -d repoOutput ]];then
    mkdir ./repoOutput
fi
if [[ ! -d tmp ]];then
    mkdir ./tmp
fi

# ===== clean some files
rm -v ./repoFiles/*txt



#
# reponame=$(echo "$domain" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z)
# echo $reponame

urlList=( "https://activecampaign.com/partner/affiliate" )
check_tools
loop_through_URLs
