## Single domain url find
```
waybackurls -no-subs "vulnweb.com" | tee waybackurls.txt
```
## Domain with sub-domain url find
```
waybackurls "vulnweb.com" | tee waybackurls.txt
```
## Specific domains url find
```
cat domains.txt | xargs -I {} sh -c 'waybackurls -no-subs {}' | tee waybackurls.txt
```
