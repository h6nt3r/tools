## Installation
```
sudo apt install build-essential libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev -y
sudo apt install ruby-full -y
sudo gem install wpscan
```
### aggressive scan
```
wpscan --url example.com --disable-tls-checks --api-token YgMoWdmOvvL5by2aIxsaoKkmOApW4sL4monb6Xby9SY -e at -e ap -e u --enumerate ap --plugins-detection aggressive --force -v -o wp_example.com.txt
```
### Normal scan
```
wpscan --url example.com --disable-tls-checks --api-token YgMoWdmOvvL5by2aIxsaoKkmOApW4sL4monb6Xby9SY -e vp,vt,u --force -v -o wp_example.com.txt
```
