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
