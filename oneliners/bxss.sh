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
    tools=( "anew" "qsreplace" "bxss" "urlfinder" "google-chrome")

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
    echo "qsreplace==============================="
    go install -v github.com/tomnomnom/qsreplace@latest
    echo "anew===================================="
    go install -v github.com/tomnomnom/anew@latest
    echo "bxss=================================="
    go install -v github.com/ethicalhackingplayground/bxss/v2/cmd/bxss@latest
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install ./google-chrome-stable*.deb -y
    sudo apt --fix-broken install -y
    sudo apt install ./google-chrome-stable*.deb -y
    echo "urlfinder===================================="
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    wget "https://raw.githubusercontent.com/h6nt3r/payloads/refs/heads/main/xss/bxssMostUsed.txt"
    wget "https://raw.githubusercontent.com/h6nt3r/payloads/refs/heads/main/xss/xssBlind.txt"
    sudo rm -r google-chrome-stable_current_amd64.deb.* bxssMostUsed.txt.* xssBlind.txt.*
    mv ~/go/bin/* /usr/local/bin/
    exit 0
fi


# Single domain
# bxss vulnerability
if [ "$1" == "-u" ]; then
    echo "Single Domain==============="
    domain=$2
    echo "$domain" | bxss -parameters -payloadFile xssBlind.txt
fi


# bxss vulnerability
if [ "$1" == "-d" ]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all | grep -avE "\.(js|css|json|ico|woff|woff2|svg|ttf|eot|png|jpg)($|\s|\?|&|#|/|\.)" | qsreplace "BXSS" | grep -a "BXSS" | anew | bxss -parameters -payloadFile bxssMostUsed.txt
fi

# Multi domain
# bxss vulnerability
if [ "$1" == "-l" ]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')
    urlfinder -d "$domain_Without_Protocol" -all | grep -avE "\.(js|css|json|ico|woff|woff2|svg|ttf|eot|png|jpg)($|\s|\?|&|#|/|\.)" | qsreplace "BXSS" | grep -a "BXSS" | anew | bxss -parameters -payloadFile bxssMostUsed.txt
fi
