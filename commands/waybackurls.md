## Single domain url find
```
waybackurls -no-subs "vulnweb.com" | tee vulnweb.com.txt
```
## Domain with sub-domain url find
```
waybackurls "vulnweb.com" | tee vulnweb.com.txt
```
