## Read PDF files
```
cat recon/all_extension_urls.txt | grep -aEi '\.pdf$' | while read -r url; do curl -s "$url" | pdftotext -q - - 2>/dev/null | grep -Eaiq '(internal use only|confidential|strictly private|personal & confidential|private|restricted|internal|not for distribution|do not share|proprietary|trade secret|classified|sensitive|bank statement|invoice|salary|contract|agreement|non disclosure|passport|social security|ssn|date of birth|credit card|identity|id number|company confidential|staff only|management only|internal only|shareholder information|Members Only)' && echo "$url"; done
```
## All backup and database files
```
cat recon/all_extension_urls.txt | grep -aE '\.zip|\.tar\.gz|\.tgz|\.7z|\.rar|\.gz|\.bz2|\.xz|\.lzma|\.z|\.cab|\.arj|\.lha|\.ace|\.arc|\.iso|\.db|\.sqlite|\.sqlite3|\.db3|\.sql|\.sqlitedb|\.sdb|\.sqlite2|\.frm|\.mdb|\.accdb|\.bak|\.backup|\.old|\.sav|\.save'
```
## All confidentials files
```
cat recon/all_extension_urls.txt | grep -aE '\.enc|\.pgp|\.locky|\.secure|\.key|\.gpg|\.asc'
```
## All microsoft document files
```
cat recon/all_extension_urls.txt | grep -aE '\.doc|\.docx|\.dot|\.dotx|\.docm|\.dotm|\.xls|\.xlsx|\.xlt|\.xltx|\.xlsm|\.xltm|\.xlsb|\.ppt|\.pptx|\.pot|\.potx|\.pps|\.ppsx|\.pptm|\.potm|\.ppsm|\.mdb|\.accdb|\.mde|\.accde|\.adp|\.accdt|\.pub|\.puz|\.one|\.onepkg'
```
## All js files
```
cat recon/all_extension_urls.txt | grep -aE '\config.js|\credentials.js|\secrets.js|\keys.js|\password.js|\api_keys.js|\auth_tokens.js|\access_tokens.js|\sessions.js|\authorization.js|\encryption.js|\certificates.js|\ssl_keys.js|\passphrases.js|\policies.js|\permissions.js|/privileges.js|\hashes.js|\salts.js|\nonces.js|\signetures.js|\digests.js|\tokens.js|\cookies.js|\topsecr3tdotnotlook.js'
```
## Installation
```
wget "https://raw.githubusercontent.com/h6nt3r/tools/refs/heads/main/personal_identification_information/pii.sh"
sudo chmod +x pii.sh
```
