#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -u               Single url enumeration"
    echo "  -f               path of js file"
    echo "  -i               Check required tool installed or not."
    echo "  -c               Installing required tools"
    echo ""
    echo -e "${BOLD_YELLOW}Usage:${NC}"
    echo -e "${BOLD_YELLOW}    $0 -u https://example.com/assets/something.js${NC}"
    echo -e "${BOLD_YELLOW}    $0 -f path/to/js/file.txt${NC}"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/m4ll0k/SecretFinder
              https://github.com/projectdiscovery/httpx"
    exit 0
}


# Function to check installed tools
check_tools() {
    tools=("secretfinder" "sort" "httpx" "sed" "head" "unzip")

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
    mkdir -p --mode=777 jshelper
    sudo apt install unzip -y
    cd jshelper

    echo "secretfinder===================================="
    cd /opt/
    sudo git clone https://github.com/m4ll0k/SecretFinder.git
    cd SecretFinder/
    sudo chmod +x ./*.py
    sudo pip3 install -r requirements.txt --break-system-packages
    cd
    sudo ln -sf /opt/SecretFinder/SecretFinder.py /usr/local/bin/secretfinder
    secretfinder -h
    cd

    cd jshelper
    echo "httpx=================================="
    wget "https://github.com/projectdiscovery/httpx/releases/download/v1.6.10/httpx_1.6.10_linux_amd64.zip"
    sudo unzip httpx_1.6.10_linux_amd64.zip
    sudo mv httpx /usr/local/bin/
    sudo chmod +x /usr/local/bin/httpx
    sudo rm -rf ./*
    httpx -h
    cd

    sudo rm -rf jshelper
    echo "If all tools are not install correctly then install it manually."
    exit 0
fi

if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi


if [[ "$1" == "-u" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed -E 's|https?://(www\.)?([^/]+).*|\2|')
    # making directory
    main_dir="jshelper/$domain_Without_Protocol"
    base_dir="$main_dir/single_url"
    jsurl="$2"

    mkdir -p $main_dir
    mkdir -p $base_dir
    chmod -R 777 $main_dir

    echo "Single url js secret finding"
    echo ""
    echo "=================================================================="
    echo "================= secretfinder checking =========================="
    echo "=================================================================="
    echo ""
    secretfinder -i "$jsurl" -o cli | tee $base_dir/secretfinder.txt
    echo ""
    echo "=================================================================="
    echo "================= secretfinder finished =========================="
    echo "=================================================================="
    echo ""

    all_secret_urls_path=$base_dir/secretfinder.txt
    all_secret_urls_count=$(cat $base_dir/secretfinder.txt | wc -l)
    echo -e "${BOLD_YELLOW}All secrets output${NC}(${RED}$all_secret_urls_count${NC}): ${BOLD_BLUE}$all_secret_urls_path${NC}"

    chmod -R 777 $main_dir
    exit 0
fi


if [[ "$1" == "-f" ]]; then
    domain_Without_Protocol=$(cat "$2" | head -n 1 | sed -E 's|https?://(www\.)?([^/]+).*|\2|')
    # making directory
    main_dir="jshelper/$domain_Without_Protocol"
    base_dir="$main_dir/file_urls"
    jsurl="$2"

    mkdir -p $main_dir
    mkdir -p $base_dir
    chmod -R 777 $main_dir
    echo "File js secret finding"
    echo ""
    echo "=================================================================="
    echo "================= secretfinder checking =========================="
    echo "=================================================================="
    echo ""

    echo "=================================================================="
    echo "Filtering JS urls"
    echo "=================================================================="

    cat "$jsurl" | sed 's/:[0-9]\+//' | grep -aiE "\.(js|json)($|\s|\?|&|#|/|\.)" | sort -u | tee $base_dir/all_js_urls.txt

    echo "=================================================================="
    echo "Filtering live js urls"
    echo "=================================================================="

    httpx -l $base_dir/all_js_urls.txt -fc 301,302,401,403,404 -duc -o $base_dir/unique_probing_urls.txt

    echo "=================================================================="
    echo "Removing duplicate JS urls"
    echo "=================================================================="

    cat $base_dir/unique_probing_urls.txt | sort -u | tee $base_dir/unique_js_urls.txt


    echo "=================================================================="
    echo "Total unique JS URLs:" $(cat $base_dir/unique_js_urls.txt | wc -l)
    echo "Secret finding on JS urls"
    echo "=================================================================="

    cat $base_dir/unique_js_urls.txt | while read urls;do secretfinder -i $urls -o cli; done | tee $base_dir/secretfinder.txt
    echo ""
    echo "=================================================================="
    echo "================= secretfinder finished =========================="
    echo "=================================================================="
    echo ""

    all_live_urls_path=$base_dir/unique_js_urls.txt
    all_live_urls=$(cat $base_dir/unique_js_urls.txt | wc -l)
    echo -e "${BOLD_YELLOW}All live js urls${NC}(${RED}$all_live_urls${NC}): ${BOLD_BLUE}$all_live_urls_path${NC}"

    all_secret_urls_path=$base_dir/secretfinder.txt
    all_secret_urls_count=$(cat $base_dir/secretfinder.txt | wc -l)
    echo -e "${BOLD_YELLOW}All secrets output${NC}(${RED}$all_secret_urls_count${NC}): ${BOLD_BLUE}$all_secret_urls_path${NC}"


    chmod -R 777 $main_dir
    exit 0
fi