## installation
```
go install -v github.com/ffuf/ffuf/v2@latest
sudo mv go/bin/ffuf /usr/local/bin/
sudo chmod +x /usr/local/bin/ffuf
ffuf -h
```
## Juicy Content
```
ffuf -w collection_payloads/content_discovery/endpoints.txt -u "https://example/FUZZ" -fs 0 -c -mc 200 -fr false -rate 10 -t 10 -v
```
### SSRF 
```
ffuf -w local_ports.txt -u "https://api.example.com/v2/test/test/download/?download_location=http://FUZZ"
```
port wordlist list <a href="https://github.com/a7madn1/Fuzzing/blob/main/localhost-port-fuzzing.txt">localhost-port-fuzzing.txt</a>
