#!/bin/bash


localOnly=1
hardFile=1 # ---------- harder than localOnly

# domain=activecampaign.com/partner/affiliate
url=https://meetfox.com/en/affiliate
domain=meetfox.com/en/affiliate
# url=https://clearout.io/affiliate
# domain=clearout.io/affiliate
#url=adzooma.com
#post_id=12
#
reponame=$(echo "$domain" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z)
echo $reponame
if [[ localOnly -eq 0 ]]; then

# echo $reponame | awk '{ sub("://", "-");gsub("\.","-");gsub("/","-"); print }'

##-->> Trafilature is used to clean and process the html page to plain text.
    #
    read -n 1 -p "trafilatura (enter t) or justext (enter j) or readability (enter r)" answer
    if [[ "$answer" == "t" ]]; then
        trafilatura -u https://$domain >$PWD/$reponame.txt
    elif [[ "$answer" == "j" ]]; then
        echo "You dont have trafilatura. Using justext"
        # we activate python virtual environment then we quit, very quick, as this is only for result
        source env/bin/activate
        python -m justext -s English -o ./$reponame.txt $url
        deactivate
    elif [[ "$answer" == "w" ]]; then
        echo "You dont have trafilatura. Now using w3m"
        # we activate python virtual environment then we quit, very quick, as this is only for result
        w3m -dump $url >./$reponame.txt





    # exit

    fi
fi

if [[ hardFile -eq 1 ]]; then
    reponame="mytest"
fi


#echo $output

#FILES="/Volumes/Snippets/find-affiliates/txtfiles/*"
#while IFS= read -r file
#do

clean=$(cat $reponame.txt)

output=$clean

# ===== QUESTIONS_TO_SELF: there must be a way to check numbers paired with percentage. Any chance of % with no numbers?
# ===== QUESTIONS_TO_SELF: do orders of search terms matter? Should we exclude some? (Eg: include "commission,every,%" but exclude "commission,%,every")

# ----- for now our code uses only dots(.) as record separator. Mayben we expand using variables
# ----- note the Record Separator can be expanded, as we decide to "zoom in" or "zoom out" on search result
# ========== awkString='BEGIN{RS="to|[:.]"}{print $0}'



# ---------- dot-separation + case-insensitive search
echo $output | awk 'BEGIN{RS="[:.]"}{if(tolower($0) ~ "commission") print $0}'





recordSeparator="[:.!]"

# ---------- Parent tree (mostly)
# ---------- Parent tree terms must exclude subtree terms (Eg: "every" is a subtree to this, so 'non-recurring' must exclude "every")
# ------------------------------ NON-RECURRING ------------------------------
echo "---------- non-recurring ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if (tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) !~ "every" \
&& tolower($0) !~ "flat" && tolower($0) !~ "first purchase" && tolower($0) !~ "fixed" && tolower($0) !~ "per" \
&& tolower($0) !~ "order" && tolower($0) !~ "refer" && tolower($0) !~ "recurring" \
) print $0}'

# ------------------------------ EVERY ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- every ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "every") print $0}'


# ------------------------------ FLAT ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- flat ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "flat") print $0}'


# ------------------------------FIRST PURCHASE ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- first purchase ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "first purchase") print $0}'


# ------------------------------ FIXED ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- fixed ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "fixed") print $0}'


# ------------------------------ PER (NOT PERIOD) ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- per (NOT period) ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "per") print $0}'


# ------------------------------ ONCE OFF ------------------------------
# ---------- dot-separation + case-insensitive search + "commission" && "%" && "flat"
echo "---------- once off ----------"
# echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "per") print $0}'


# ------------------------------ COMMISSION ORDER ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- commission order ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "order") print $0}'


# ------------------------------ COMMISSION REFERRAL ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- commission order ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "refer") print $0}'


# ------------------------------ COMMISSION PURCHASE ------------------------------
# ---------- subtree (to non-recurring)
echo "---------- commission purchase ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "purchase") print $0}'


# ------------------------------ COMMISSION SALE ------------------------------
# -------------------- has unique "affiliate", so this might change
# ---------- subtree (to non-recurring)
echo "---------- commission sale ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "sale") print $0}'


# ------------------------------ RECURRING ------------------------------
# ---------- subtree (to non-recurring)
# ---------- parent (to others below)
echo "---------- recurring ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) !~ "monthly" && tolower($0) !~ "sales" ) \
{ num=split($0, a, "%"); if(num < 3) print $0 } \
}'
# echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "%") num=split($0, a, "%"); if(num > 2) print $0;}'


# ------------------------------ RECURRING MONTHLY ------------------------------
# ---------- subtree (to recurring)
echo "---------- recurring monthly ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) ~ "monthly" \
) print $0}'


# ------------------------------ SALES ------------------------------
# ---------- subtree (to recurring)
echo "---------- sales ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "commission" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
&& tolower($0) ~ "sale" \
) print $0}'


# ------------------------------ REVENUE ------------------------------
# ---------- (unique)
echo "---------- revenue ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "revenue" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}'


# ------------------------------ FEES ------------------------------
# ---------- (unique)
echo "---------- fees ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "fee" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}'


# ------------------------------ INITIAL + RECURRING ------------------------------
# ---------- (unique)
# ----- may include additional condition like "sales"
echo "---------- initial + recurring ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "initial" && tolower($0) ~ "%" && tolower($0) ~ "recurring" \
) print $0}'


# ------------------------------ SALES + RENEWALS ------------------------------
# ---------- (unique)
echo "---------- sales + renewals ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "sale" && tolower($0) ~ "%" && tolower($0) ~ "renewal" \
) print $0}'


# ------------------------------ LIFETIME ------------------------------
# ---------- (assume unique)
echo "---------- lifetime ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "lifetime" && tolower($0) ~ "%" \
) print $0}'


# ------------------------------ MULTI COMMISSION ------------------------------
# ---------- subtree (to recurring) (we exclude multi-% in 'recurring')
echo "---------- multi commission ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "%") { num=split($0, a, "%"); if(num > 2) print $0;} }'


# ------------------------------ COOKIES ------------------------------
# ---------- (unique)
echo "---------- cookies ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "cookie" && tolower($0) ~ "[0-9]") print $0; }'
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "link" && tolower($0) ~ "tracking") print $0; }'


# ------------------------------ PAYMENT METHOD ------------------------------
# ---------- (unique & several combinations)
echo "---------- payment method ----------"
paymentm=("paypal" "credit" "bank transfer" "wire transfer" "payoneer" "wise transfer" "payone" "cheque" "check" "bitcoin")
for i in ${paymentm[@]}
do
    echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "pay" && tolower($0) ~ "'$i'") print $0; }'
    echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "paid" && tolower($0) ~ "'$i'") print $0; }'
done



# ------------------------------ MONTHLY PAYOUT / MINIMUM PAYOUT------------------------------
# ---------- (unique)
echo "---------- payout ----------"
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "monthly" && tolower($0) ~ "payout") print $0; }'
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "minimum" && tolower($0) ~ "payout") print $0; }'
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "monthly" && tolower($0) ~ "withdrawal") print $0; }'
echo $output | awk 'BEGIN{RS="'$recordSeparator'"}{if(tolower($0) ~ "minimum" && tolower($0) ~ "withdrawal") print $0; }'
