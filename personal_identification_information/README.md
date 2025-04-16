## Read PDF files
```
cat recon/all_extension_urls.txt | grep -aEi '\.pdf$' | while read -r url; do curl -s "$url" | pdftotext -q - - 2>/dev/null | grep -Eaiq '(internal use only|confidential|strictly private|personal & confidential|private|restricted|internal|not for distribution|do not share|proprietary|trade secret|classified|sensitive|bank statement|invoice|salary|contract|agreement|non disclosure|passport|social security|ssn|date of birth|credit card|identity|id number|company confidential|staff only|management only|internal only|shareholder information|Members Only)' && echo "$url"; done
```
## All backup and database files
```
cat recon/all_extension_urls.txt | grep -aiE '\.(zip|tar\.gz|tgz|7z|rar|gz|bz2|xz|lzma|z|cab|arj|lha|ace|arc|iso|db|sqlite|sqlite3|db3|sql|sqlitedb|sdb|sqlite2|frm|mdb|accdb|bak|backup|old|sav|save)$'
```
## All confidentials files
```
cat recon/all_extension_urls.txt | grep -aE '\.enc|\.pgp|\.locky|\.secure|\.key|\.gpg|\.asc'
```
## All microsoft document files
```
cat recon/all_extension_urls.txt | grep -aiE '\.(doc[xm]?|dot[xm]?|xls[xmb]?|xlt[xm]?|ppt[xm]?|pot[xm]?|pps[xm]?|mdb|accd[be]|adp|accdt|pub|puz|one(pkg)?)$'
```
## All js files
```
cat recon/all_extension_urls.txt | grep -aiE '\.(config|credentials|secrets|keys|password|api_keys|auth_tokens|access_tokens|sessions|authorization|encryption|certificates|ssl_keys|passphrases|policies|permissions|privileges|hashes|salts|nonces|signetures|digests|tokens|cookies|topsecr3tdotnotlook)\.js$'
```
## Installation
```
wget "https://raw.githubusercontent.com/h6nt3r/tools/refs/heads/main/personal_identification_information/pii.sh"
sudo chmod +x pii.sh
./pii.sh -h
```
