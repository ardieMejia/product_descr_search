# affiliate-grep

Extract specific strings of information from affiliate program webpages.

## Overview

In short, the script cleans HTML text and we're looking to extract data from that using whatever method makes sence.

1. It reads from a URL list
2. Out put clean text to file
3. Extract strings
4. Structures stings into JSON or CSV format.

Example Output

```
{
  "domain": "example.com",
  "post_id": "123",
  "affiliate_commission": {
    "commission_1": "30%",
    "commission_2": "25%"
  },
  "affiliate_payout": {
    "payout_1": "paypal",
    "payout_2": "wire transfer"
  }
}

```
