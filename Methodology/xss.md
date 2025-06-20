# <center>XSS Finding Methodology</center>
### Required Tools
[urlfinder](https://github.com/projectdiscovery/urlfinder)
### Making directory
```
sudo mkdir -m 777 -p xss/ncs.com.cn
```
# Finding Subdomains
### Subfinder
```
subfinder -d "ncs.com.cn" -all -recursive -o xss/ncs.com.cn/subfinder.txt
```
### Sublist3r
```
sublist3r -d "ncs.com.cn" -e baidu,yahoo,google,bing,ask,netcraft,virustotal,threatcrowd,crtsh,passivedns -v -o xss/ncs.com.cn/sublist3r.txt
```
### Subdominator
```
subdominator -d "ncs.com.cn" -all -V -t 20 -o xss/ncs.com.cn/subdominator.txt
```
### Making unique
```
cat xss/ncs.com.cn/subfinder.txt xss/ncs.com.cn/sublist3r.txt xss/ncs.com.cn/subdominator.txt | sort -u | tee xss/ncs.com.cn/all_subdomains.txt
```
### Live domains
```
httpx -l xss/ncs.com.cn/all_subdomains.txt -mc 200,301 -duc -t 80 -o xss/ncs.com.cn/live_domains.txt
```
### Extract all domains
```
cat xss/ncs.com.cn/live_domains.txt | sed -E 's,https?://(www\.)?,,' | anew | tee xss/ncs.com.cn/final_domains.txt
```
### Urlfinder
```
urlfinder -all -list xss/ncs.com.cn/final_domains.txt -fs fqdn -o xss/ncs.com.cn/urlfinder.txt
```
### Katana
```
katana -list xss/ncs.com.cn/final_domains.txt -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o xss/ncs.com.cn/katana.txt
```
### Waybackurls
```
cat xss/ncs.com.cn/final_domains.txt | while read waybackurl;do waybackurls -no-subs "$waybackurl";done | tee xss/ncs.com.cn/waybackurls.txt
```
### Waymore
```
waymore -i xss/ncs.com.cn/final_domains.txt -n -mode U -xcc -p 2 -t 20 -oU xss/ncs.com.cn/waymore.txt
```
### Removing duplicates
```
cat xss/ncs.com.cn/urlfinder.txt xss/ncs.com.cn/katana.txt xss/ncs.com.cn/waybackurls.txt xss/ncs.com.cn/waymore.txt | sed 's/:[0-9]\+//' | anew | tee xss/ncs.com.cn/all_unique_urls.txt
```
### Parameter find
```
cat xss/ncs.com.cn/all_unique_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee xss/ncs.com.cn/all_params.txt
```
### Removing 99% similar parameters
```
cat xss/ncs.com.cn/all_params.txt | awk -F'[?&=]' '!seen[$1$2]++' | tee xss/ncs.com.cn/live_similar_params.txt
```
### Find live urls
```
httpx -l xss/ncs.com.cn/live_similar_params.txt -mc 200,401 -duc -t 80 -o xss/ncs.com.cn/live_params.txt
```
### Count total number of parameter
```
cat xss/ncs.com.cn/live_params.txt | wc -l
```
### Reflection find
```
reflection -f xss/ncs.com.cn/live_params.txt -p "FUZZ" -o xss/ncs.com.cn/all_urls_reflected_params.txt
```
### Ready urls for RXSS
```
cat xss/ncs.com.cn/all_urls_reflected_params.txt | sed 's/FUZZ/*/g' | tee xss/ncs.com.cn/all_urls_reflected_params_ready.txt
```
### Reflected xss testing
```
xsser -f xss/ncs.com.cn/all_urls_reflected_params_ready.txt -p payloads/collection_payloads/xss/xssCollected.txt -o xss/ncs.com.cn/rxss_found.txt
```
### Nuclei Reflected xss testing
```
nuclei -l xss/ncs.com.cn/all_urls_reflected_params.txt -t payloads/pvtTemplate/ -tags rxss -dast -duc -o xss/ncs.com.cn/nuclei_found.txt
```
### Bxsser blind XSS testing 1
```
bxsser -f xss/ncs.com.cn/live_params.txt -p payloads/collection_payloads/xss/blindxssreport.txt
```
### Bxss blind XSS testing 2
```
cat xss/ncs.com.cn/live_params.txt | bxss -t -X GET,POST -pf payloads/collection_payloads/xss/xssBlind.txt
```
### One liners of Blind XSS
```
urlfinder -all -d "ncs.com.cn" | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew>ncs.com.cn.txt;cat ncs.com.cn.txt | bxsser -p payloads/collection_payloads/xss/blindxssreport.txt
```