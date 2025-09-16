#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -l http://example.com"
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
    tools=( "bxss" "subfinder" "urlfinder" "httpx" "katana" "google-chrome" "anew" "unfurl" "xargs")

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
    mkdir -p --mode=777 bxsser

    cd bxsser
    sudo apt install unzip -y
    echo "bxss=================================="
    wget "https://github.com/ethicalhackingplayground/bxss/releases/download/v0.0.3/bxss_Linux_x86_64.tar.gz"
    sudo tar -xvzf bxss_Linux_x86_64.tar.gz
    sudo mv bxss /usr/local/bin/
    sudo chmod +x /usr/local/bin/bxss
    bxss -h
    sudo rm -rf ./*
    cd

    cd bxsser
    echo "httpx=================================="
    sudo wget "https://github.com/projectdiscovery/httpx/releases/download/v1.7.1/httpx_1.7.1_linux_amd64.zip"
    sudo unzip httpx_1.7.1_linux_amd64.zip
    sudo mv httpx /usr/local/bin/
    sudo chmod +x /usr/local/bin/httpx
    httpx -h
    sudo rm -rf ./*
    cd


    cd bxsser
    echo "subfinder=================================="
    sudo wget "https://github.com/projectdiscovery/subfinder/releases/download/v2.8.0/subfinder_2.8.0_linux_amd64.zip"
    sudo unzip subfinder_2.8.0_linux_amd64.zip
    sudo mv subfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/subfinder
    sudo rm -rf ./*
    subfinder -h
    cd

    cd bxsser
    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    sudo unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    urlfinder -h
    sudo rm -rf ./*
    cd

    cd bxsser
    echo "google-chrome===================================="
    sudo wget "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    sudo apt --fix-broken install -y
    sudo apt update --fix-missing
    sudo apt install ./google-chrome-stable*.deb -y
    sudo apt update --fix-missing
    sudo apt install ./google-chrome-stable*.deb -y
    sudo rm -rf ./*
    cd

    cd bxsser
    echo "katana=================================="
    sudo wget "https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
    sudo unzip katana_1.1.0_linux_amd64.zip
    sudo mv katana /usr/local/bin/
    sudo chmod +x /usr/local/bin/katana
    sudo rm -rf ./*
    katana -h
    cd

    cd bxsser
    echo "anew=================================="
    sudo wget "https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz"
    sudo tar -xvzf anew-linux-amd64-0.1.1.tgz
    sudo mv anew /usr/local/bin/
    sudo chmod +x /usr/local/bin/anew
    anew -h
    sudo rm -rf ./*
    cd

    cd bxsser
    echo "unfurl=================================="
    wget "https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz"
    sudo tar -xzvf unfurl-linux-amd64-0.4.3.tgz
    sudo mv unfurl /usr/local/bin/
    sudo chmod +x /usr/local/bin/unfurl
    unfurl -h
    sudo rm -rf ./*
    cd

    echo "Downloading payloads===================================="
    sudo rm -rf xssBlind.*
    wget "https://raw.githubusercontent.com/h6nt3r/collection_payloads/refs/heads/main/xss/xssBlind.txt"

    sudo rm -rf bxsser
    
    exit 0
fi

# Single domain
# bxss vulnerability
if [ "$1" == "-u" ]; then
    echo "Single Domain==============="
    domain=$2
    echo "$domain" | bxss -t -X GET -pf xssBlind.txt
    exit 0
fi

# bxss vulnerability
if [ "$1" == "-d" ]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)

    main_dir="xss/$domain_Without_Protocol"
    base_dir="$main_dir/bxss/single_domain"

    sudo mkdir -p --mode=777 $main_dir

    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all -duc -v -o $base_dir/urlfinder.txt

    katana -u "$domain_Without_Protocol" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o $base_dir/katana.txt

    cat $base_dir/urlfinder.txt $base_dir/katana.txt | sed 's/:[0-9]\+//' | grep -aiE "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|jpeg|js|json|pdf|xml|gif)($|\s|\?|&|#|/|\.)" | anew>$base_dir/all_urls.txt

    sudo rm -rf $base_dir/urlfinder.txt $base_dir/katana.txt

    cat $base_dir/all_urls.txt | bxss -t -X GET -pf xssBlind.txt
    exit 0
fi

# Multi domain
if [ "$1" == "-l" ]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)

    main_dir="xss/$domain_Without_Protocol"
    base_dir="$main_dir/bxss/multi_domain"

    sudo mkdir -p --mode=777 $main_dir

    subfinder -d "$domain_Without_Protocol" -all -recursive -duc -nc -o $base_dir/subfinder.txt

    httpx -l $base_dir/subfinder.txt -mc 200 -duc | sed -E 's,https?://(www\.)?,,' | tee $base_dir/httpx.txt

    urlfinder -list $base_dir/httpx.txt -all -duc -v -o $base_dir/urlfinder.txt

    katana -list $base_dir/httpx.txt -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o $base_dir/katana.txt

    cat $base_dir/urlfinder.txt $base_dir/katana.txt | sed 's/:[0-9]\+//' | grep -aiE "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|jpeg|js|json|pdf|xml|gif)($|\s|\?|&|#|/|\.)" | anew>$base_dir/all_urls.txt

    sudo rm -rf $base_dir/subfinder.txt $base_dir/httpx.txt $base_dir/urlfinder.txt $base_dir/katana.txt

    cat $base_dir/all_urls.txt | bxss -t -X GET -pf xssBlind.txt
    exit 0
fi
