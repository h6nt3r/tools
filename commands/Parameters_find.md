## Single Domain parameter find
```
echo "vulnweb.com" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | sed 's/:[0-9]\+//' | iconv -f ISO-8859-1 -t UTF-8 | grep -aE '\?.*=.*(&.*)?' | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | awk -F'[?&=]' '!seen[$1$2]++' | anew | tee parameters_vulnweb.com.txt
```
## Domain with sub-domain parameter find
```
echo "vulnweb.com" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | sed 's/:[0-9]\+//' | iconv -f ISO-8859-1 -t UTF-8 | grep -aE '\?.*=.*(&.*)?' | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | awk -F'[?&=]' '!seen[$1$2]++' | anew | tee parameters_vulnweb.com.txt
```
