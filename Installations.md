### ghauri
```
cd /opt/ && sudo git clone https://github.com/r0oth3x49/ghauri.git && cd ghauri/
sudo chmod +x setup.py
sudo python3 -m pip install --upgrade -r requirements.txt --break-system-packages
sudo python3 -m pip install -e . --break-system-packages
sudo python3 setup.py install
cd
ghauri -h
```
### sqlmap
```
cd /opt/ && sudo git clone https://github.com/sqlmapproject/sqlmap.git
cd
sudo ln -sf /opt/sqlmap/sqlmap.py /usr/local/bin/sqlmap
sqlmap -h
```
### Dirsearch
```
cd /opt/ && sudo git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch/ && sudo chmod +x ./*
sudo pip3 install -r requirements.txt --break-system-packages
sudo python3 setup.py install
cd
dirsearch -h
```
### Ffuf
```
go install -v github.com/ffuf/ffuf/v2@latest
sudo mv go/bin/ffuf /usr/local/bin/
sudo chmod +x /usr/local/bin/ffuf
ffuf -h
```
### Katana 1.1.0
```
wget "https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
unzip katana_1.1.0_linux_amd64.zip
sudo mv katana /usr/local/bin/
sudo chmod +x /usr/local/bin/katana
katana -h
```
### wpscan
```
sudo apt install build-essential libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev -y
sudo apt install ruby-full -y
sudo gem install wpscan
```
