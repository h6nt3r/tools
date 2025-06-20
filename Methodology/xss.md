# <center>XSS Finding Methodology</center>
### Required Tools
[urlfinder](https://github.com/projectdiscovery/urlfinder)
### Making directory
```
sudo mkdir -m 777 -p xss/vulnweb.com
```
# Finding Subdomains
### Subfinder
```
subfinder -d "vulnweb.com" -all -recursive -o xss/vulnweb.com/subfinder.txt
```
### Sublist3r
```
sublist3r -d "vulnweb.com" -e baidu,yahoo,google,bing,ask,netcraft,virustotal,threatcrowd,crtsh,passivedns -v -o xss/vulnweb.com/sublist3r.txt
```
### Subdominator
```
subdominator -d "vulnweb.com" -all -V -t 20 -o xss/vulnweb.com/subdominator.txt
```
### Making unique
```
cat xss/vulnweb.com/subfinder.txt xss/vulnweb.com/sublist3r.txt xss/vulnweb.com/subdominator.txt | sort -u | tee xss/vulnweb.com/all_subdomains.txt
```
### Live domains
```
httpx -l xss/vulnweb.com/all_subdomains.txt -mc 200,301 -duc -t 80 -o xss/vulnweb.com/live_domains.txt
```
### Extract all domains
```
cat xss/vulnweb.com/live_domains.txt | sed -E 's,https?://(www\.)?,,' | anew | tee xss/vulnweb.com/final_domains.txt
```
### Urlfinder
```
urlfinder -all -list xss/vulnweb.com/final_domains.txt -fs fqdn -o xss/vulnweb.com/urlfinder.txt
```
### Katana
```
katana -list xss/vulnweb.com/final_domains.txt -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o xss/vulnweb.com/katana.txt
```
### Waybackurls
```
cat xss/vulnweb.com/final_domains.txt | while read waybackurl;do waybackurls -no-subs "$waybackurl";done | tee xss/vulnweb.com/waybackurls.txt
```
### Waymore
```
waymore -i xss/vulnweb.com/final_domains.txt -n -mode U -xcc -p 2 -t 20 -oU xss/vulnweb.com/waymore.txt
```
### Removing duplicates
```
cat xss/vulnweb.com/urlfinder.txt xss/vulnweb.com/katana.txt xss/vulnweb.com/waybackurls.txt xss/vulnweb.com/waymore.txt | sed 's/:[0-9]\+//' | anew | tee xss/vulnweb.com/all_unique_urls.txt
```
### Parameter find
```
cat xss/vulnweb.com/all_unique_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee xss/vulnweb.com/all_params.txt
```
### Removing 99% similar parameters
```
cat xss/vulnweb.com/all_params.txt | awk -F'[?&=]' '!seen[$1$2]++' | tee xss/vulnweb.com/live_similar_params.txt
```
### Find live urls
```
httpx -l xss/vulnweb.com/live_similar_params.txt -mc 200,401 -duc -t 80 -o xss/vulnweb.com/live_params.txt
```
### Count total number of parameter
```
cat xss/vulnweb.com/live_params.txt | wc -l
```
### Reflection find
```
reflection -f xss/vulnweb.com/live_params.txt -p "FUZZ" -o xss/vulnweb.com/all_urls_reflected_params.txt
```
### Ready urls for RXSS
```
cat xss/vulnweb.com/all_urls_reflected_params.txt | sed 's/FUZZ/*/g' | tee xss/vulnweb.com/all_urls_reflected_params_ready.txt
```
### Reflected xss testing
```
xsser -f xss/vulnweb.com/all_urls_reflected_params_ready.txt -p payloads/collection_payloads/xss/xssCollected.txt -o xss/vulnweb.com/rxss_found.txt
```
### Nuclei Reflected xss testing
```
nuclei -l xss/vulnweb.com/all_urls_reflected_params.txt -t payloads/pvtTemplate/ -tags rxss -dast -duc -o xss/vulnweb.com/nuclei_found.txt
```
### Bxsser blind XSS testing 1
```
bxsser -f xss/vulnweb.com/live_params.txt -p payloads/collection_payloads/xss/blindxssreport.txt
```
### Bxss blind XSS testing 2
```
cat xss/vulnweb.com/live_params.txt | bxss -t -X GET,POST -pf payloads/collection_payloads/xss/xssBlind.txt
```
### One liners of Blind XSS
```
urlfinder -all -d "vulnweb.com" | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew>vulnweb.com.txt;cat vulnweb.com.txt | bxsser -p payloads/collection_payloads/xss/blindxssreport.txt
```