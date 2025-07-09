## installation
```
wget "https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
unzip katana_1.1.0_linux_amd64.zip
sudo mv katana /usr/local/bin/
sudo chmod +x /usr/local/bin/katana
katana -h
```

## Single domain url find
```
katana -u "vulnweb.com" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o katana.txt
```
## Domain with sub-domain url find
```
katana -u "vulnweb.com" -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o katana.txt
```
## Specific domains url find
```
katana -list domains.txt -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o katana.txt
```
