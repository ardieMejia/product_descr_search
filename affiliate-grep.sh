#!/bin/bash



# domain=activecampaign.com/partner/affiliate
url=https://xoba.co.uk/affiliate
domain=xoba.co.uk/affiliate
# url=https://clearout.io/affiliate
# domain=clearout.io/affiliate
#url=adzooma.com
#post_id=12
#
reponame=$(echo "$domain" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z)
echo $reponame
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
elif [[ "$answer" == "r" ]]; then
    echo "You dont have trafilatura. Using justext"
    # we activate python virtual environment then we quit, very quick, as this is only for result
    source env/bin/activate
    python -m justext -s English -o ./$reponame.txt $url
    deactivate





    # exit
fi




#echo $output

#FILES="/Volumes/Snippets/find-affiliates/txtfiles/*"
#while IFS= read -r file
#do

clean=$(cat $reponame.txt)

output=$clean

##-->> Looking for xx% plus commission
# Really what we want is a way to find anything between, the percentage value and probably the word commission.
# For example:
# 20% lifetime recurring commission
# 30% reccuring monthly commission
echo $output | grep -oE -i '[0-9][0-9]\%+' | head -3
echo $output | grep -oE -i '[0-9][0-9]\% (commission)' | sort -u | head -3
echo $output | grep -oE -i '[0-9][0-9]\% (monthly commission)' | sort -u | head -3
echo $output | grep -oE -i '[0-9][0-9]\% (recurring commission)' | sort -u | head -3

##-->> Credit Only
# Some offer credit and not payout much like Digital Ocean
#
##-->> This is just finding the single values for now for testing
echo $output | grep -Eo -i '(recurring)' | sort -u | head -1
echo $output | grep -Eo '(commission)' | sort -u | head -1
echo $output | grep -oE 'Up to' | sort -u | head -1
echo $output | grep -oEi '(lifetime commission)' | sort -u | head -1

##-->> Payout method
echo $output | grep -Eoi '(paypal)' | sort -u | head -1
echo $output | grep -Eoi '(paypal)' | sort -u | head -1

##-->> Payout Period
# Monthly payouts (no minimum)
# Minimum balance of $50 before we can process
echo $output | grep -E -o -i 'monthly payout' | sort -u | head -1
echo $output | grep -E -o -i 'no minimum' | sort -u | head -1

##-->> Per Sale based commission and not a percentage value.
echo $output | grep -Eoi '(every sale)' | sort -u | head -1

##-->> Cookie Period / Window
# This value will change and might not be mentioned at all
# For Example:
# 120 day cookie window
echo $output | grep -Eoi 'cookies' | sort -u | head -1

#30% commission rate
#25% from each payment credited into your account

#done

#echo $output | grep -Eo '[:digit:]'
#echo $output | grep -Eo '^[0-9]\{1,5\}$'
#echo $output | awk -n "/[^0-9]*/,/cookies/p"
#echo $output | grep -oE -P -i '(?<=[0-9][0-9]).*(?=cookies)'
#echo $output | sed -e 's/[0-9][0-9]\(.*\)cookies/\1/'
#echo $output | sed -n '/[0-9]/,/cookies/p'
#echo $output | grep -E '(lifetime|Lifetime)' | sort -u | head -1
#echo $output | grep -E '(paypal|Paypal)' | sort -u | head -1
#echo $output | grep -Eoi '(?[0-9][0-9])(\bwindow)' | sort -u | head -1
#echo $output | ggrep -oP '(?<=commision\s/)\w+'
#echo $output | ggrep -oP '(?<=commision\s: )[^ ]*'

#grep -E -i 'og\:description' | grep -E -i 'minimum' | grep -E -w -v '20% commission'
