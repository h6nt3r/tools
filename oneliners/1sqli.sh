#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -l http://example.com -all"
    echo "     $0 -l http://example.com -t"
    echo ""
    echo "Techniques: -all, -b, -t, -e, -bb"
    echo "          -all    All type of SQLi"
    echo "          -b      Blind sqli"
    echo "          -t      Time based sqli"
    echo "          -e      Error based sqli"
    echo "          -bb     Boolean based sqli"
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
    tools=("unfurl" "anew" "httpx" "urlfinder" "ghauri" "iconv")

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
    mkdir -p --mode=777 1sqli
    cd 1sqli
    sudo apt install unzip -y

    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    sudo rm -rf ./*
    urlfinder -h


    echo "httpx=================================="
    wget "https://github.com/projectdiscovery/httpx/releases/download/v1.6.10/httpx_1.6.10_linux_amd64.zip"
    sudo unzip httpx_1.6.10_linux_amd64.zip
    sudo mv httpx /usr/local/bin/
    sudo chmod +x /usr/local/bin/httpx
    sudo rm -rf ./*
    httpx -h

    echo "anew=================================="
    wget "https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz"
    sudo tar -xzvf anew-linux-amd64-0.1.1.tgz
    sudo mv anew /usr/local/bin/
    sudo chmod +x /usr/local/bin/anew
    sudo rm -rf ./*
    anew -h

    echo "ghauri=================================="
    cd /opt/ && sudo git clone https://github.com/r0oth3x49/ghauri.git && cd ghauri/
    sudo chmod +x setup.py
    sudo python3 -m pip install --upgrade -r requirements.txt --break-system-packages
    sudo python3 -m pip install -e . --break-system-packages
    sudo python3 setup.py install
    cd
    ghauri -h
    cd 1sqli


    echo "unfurl=================================="
    wget "https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz"
    sudo tar -xzvf unfurl-linux-amd64-0.4.3.tgz
    sudo mv unfurl /usr/local/bin/
    sudo chmod +x /usr/local/bin/unfurl
    sudo rm -rf ./*
    unfurl -h

    cd
    sudo rm -rf 1sqli
    exit 0
fi


# All sqlis
if [[ "$1" == "-l" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p "$base_dir"
    chmod -R 777 "$main_dir"

    urlfinder -d "$domain_Without_Protocol" -all | grep -aiE "[&=]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|gif|js|json)($|\s|\?|&|#|/|\.)" | awk -F'[?&=]' '!seen[$1$2]++' | iconv -f ISO-8859-1 -t UTF-8 | anew | httpx -duc -sc | grep -aiE "200|301|302|500" | awk '{print $1}' | anew>$base_dir/sqli.txt;ghauri -m $base_dir/sqli.txt --batch --dbs --random-agent
    exit 0
fi


if [[ "$1" == "-l" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p "$base_dir"
    chmod -R 777 "$main_dir"

    urlfinder -d "$domain_Without_Protocol" -all | grep -aiE "[&=]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|gif|js|json)($|\s|\?|&|#|/|\.)" | awk -F'[?&=]' '!seen[$1$2]++' | iconv -f ISO-8859-1 -t UTF-8 | anew | httpx -duc -sc | grep -aiE "200|301|302|500" | awk '{print $1}' | anew>$base_dir/sqli.txt;ghauri -m $base_dir/sqli.txt --batch --tech=T --dbs --random-agent
    exit 0
fi
