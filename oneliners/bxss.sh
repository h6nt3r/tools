#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -d http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -u               Single url scan"
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
    tools=( "bxss" "urlfinder" "gau" "google-chrome")

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
    echo "bxss=================================="
    wget "https://github.com/ethicalhackingplayground/bxss/releases/download/v0.0.3/bxss_Linux_x86_64.tar.gz"
    sudo tar -xvzf bxss_Linux_x86_64.tar.gz
    sudo mv bxss /usr/local/bin/
    sudo chmod +x /usr/local/bin/bxss
    bxss -h
    sudo rm -rf ./*.md ./*.tar* ./*.zip
    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    urlfinder -h
    sudo rm -rf ./*.md ./*.tar* ./*.zip
    sudo rm -rf google-chrome-stable* bxssMostUsed.txt* xssBlind.txt* headers_for_xss.txt*
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt --fix-broken install -y
    sudo apt install ./google-chrome-stable*.deb -y
    wget "https://raw.githubusercontent.com/h6nt3r/payloads/refs/heads/main/xss/bxssMostUsed.txt"
    wget "https://raw.githubusercontent.com/h6nt3r/payloads/refs/heads/main/xss/xssBlind.txt"
    wget "https://raw.githubusercontent.com/h6nt3r/payloads/refs/heads/main/xss/headers_for_xss.txt"
    wget "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
    tar -xzf gau_2.2.4_linux_amd64.tar.gz
    sudo mv gau /usr/local/bin/
    gau -h
    sudo rm -rf ./*.md ./*.tar* ./*.zip
    exit 0
fi

# Single domain
# bxss vulnerability
if [ "$1" == "-u" ]; then
    echo "Single Domain==============="
    domain=$2
    echo "$domain" | bxss -t -X GET,POST -pf xssBlind.txt
fi

# bxss vulnerability
if [ "$1" == "-d" ]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')

    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -fs fqdn -all && gau {} --providers wayback,commoncrawl,otx,urlscan' | sort -u | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|xml)($|\s|\?|&|#|/|\.)" | sort -u | sed 's/:[0-9]\+//' | tee $domain_Without_Protocol.txt;cat $domain_Without_Protocol.txt | bxss -t -X GET,POST -hf headers_for_xss.txt -pf bxssMostUsed.txt
fi

# Multi domain
# bxss vulnerability
if [ "$1" == "-l" ]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')

    echo "$domain_Without_Protocol" | xargs -I {} sh -c 'urlfinder -d {} -all && gau {} --subs --providers wayback,commoncrawl,otx,urlscan' | sort -u | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|xml)($|\s|\?|&|#|/|\.)" | sort -u | sed 's/:[0-9]\+//' | tee $domain_Without_Protocol.txt;cat $domain_Without_Protocol.txt | bxss -t -X GET,POST -hf headers_for_xss.txt -pf bxssMostUsed.txt
fi
