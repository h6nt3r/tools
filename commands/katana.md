## Single domain url find
```
katana -u "vulnweb.com" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o katana.txt
```
## Domain with sub-domain url find
```
katana -u "vulnweb.com" -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o katana.txt
```
