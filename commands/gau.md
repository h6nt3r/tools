## Single domain
```
gau "vulnweb.com" --providers wayback,commoncrawl,otx,urlscan --verbose --o gau.txt
```
## Domain with sub-domain url find
```
gau "vulnweb.com" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o gau.txt
```
## Specific domains url find
```
cat domains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o gau.txt
```
