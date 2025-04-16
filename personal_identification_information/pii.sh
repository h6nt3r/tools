#!/usr/bin/env bash
BOLD_BLUE="\033[1;34m"
RED="\033[0;31m"
NC="\033[0m"
BOLD_YELLOW="\033[1;33m"

# Function to display usage message
display_usage() {
    echo ""
    echo "Options:"
    echo "     -h               Display this help message"
    echo "     -d               Single Domain hunting"
    echo "     -l               Multi Domain hunting"
    echo "     -i               Check required tool installed or not."
    echo "     -c               Installing required tools"
    echo -e "${BOLD_YELLOW}Usage:${NC}"
    echo -e "${BOLD_YELLOW}    $0 -d http://example.com${NC}"
    echo -e "${BOLD_YELLOW}    $0 -l http://example.com${NC}"
    exit 0
}

# Function to check installed tools
check_tools() {
    tools=("gau" "urlfinder" "anew" "pdftotext")

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
    echo "anew===================================="
    wget "https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz"
    tar -xzf anew-linux-amd64-0.1.1.tgz
    sudo mv anew /usr/local/bin/
    sudo chmod +x /usr/local/bin/anew
    anew -h
    echo "pdftotext===================================="
    wget "https://github.com/h6nt3r/tools/raw/refs/heads/main/pdftotext"
    sudo chmod +x ./pdftotext
    sudo mv ./pdftotext /usr/local/bin/
    pdftotext -h

    exit 0
fi

# help function execution
if [[ "$1" == "-h" ]]; then
    display_usage
    exit 0
fi

# single domain url getting
if [[ "$1" == "-d" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https\?://\|www\.,,g')
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/recon"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt | sed 's/:[0-9]\+//' | anew $base_dir/all_urls.txt
    cat $base_dir/all_urls.txt | grep -aiE '\.(zip|tar\.gz|tgz|7z|rar|gz|bz2|xz|lzma|z|cab|arj|lha|ace|arc|iso|db|sqlite|sqlite3|db3|sql|sqlitedb|sdb|sqlite2|frm|mdb|accd[be]|adp|accdt|pub|puz|one(pkg)?|doc[xm]?|dot[xm]?|xls[xmb]?|xlt[xm]?|ppt[xm]?|pot[xm]?|pps[xm]?|pdf|bak|backup|old|sav|save|env|txt|js|json)$' | anew $base_dir/all_extension_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_urls_params.txt

    sudo rm -rf $base_dir/urlfinder.txt $base_dir/gau.txt

    all_urls_path=$base_dir/all_urls.txt
    all_urls_count=$(cat $base_dir/all_urls.txt | wc -l)
    echo -e "${BOLD_YELLOW}All urls${NC}(${RED}$all_urls_count${NC}): ${BOLD_BLUE}$all_urls_path${NC}"

    all_extension_urls_path=$base_dir/all_extension_urls.txt
    all_extension_urls_count=$(cat $base_dir/all_extension_urls.txt | wc -l)
    echo -e "${BOLD_YELLOW}All extension urls${NC}(${RED}$all_extension_urls_count${NC}): ${BOLD_BLUE}$all_extension_urls_path${NC}"

    all_param_urls_path=$base_dir/all_urls_params.txt
    all_param_urls_count=$(cat $base_dir/all_urls_params.txt | wc -l)
    echo -e "${BOLD_YELLOW}All param urls${NC}(${RED}$all_param_urls_count${NC}): ${BOLD_BLUE}$all_param_urls_path${NC}"

    chmod -R 777 $main_dir

    exit 0
fi



# multi domain url getting
if [[ "$1" == "-l" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https\?://\|www\.,,g')
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/recon"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt | sed 's/:[0-9]\+//' | anew $base_dir/all_urls.txt
    cat $base_dir/all_urls.txt | grep -aiE '\.(zip|tar\.gz|tgz|7z|rar|gz|bz2|xz|lzma|z|cab|arj|lha|ace|arc|iso|db|sqlite|sqlite3|db3|sql|sqlitedb|sdb|sqlite2|frm|mdb|accd[be]|adp|accdt|pub|puz|one(pkg)?|doc[xm]?|dot[xm]?|xls[xmb]?|xlt[xm]?|ppt[xm]?|pot[xm]?|pps[xm]?|pdf|bak|backup|old|sav|save|env|txt|js|json)$' | anew $base_dir/all_extension_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_urls_params.txt

    sudo rm -rf $base_dir/urlfinder.txt $base_dir/gau.txt

    all_urls_path=$base_dir/all_urls.txt
    all_urls_count=$(cat $base_dir/all_urls.txt | wc -l)
    echo -e "${BOLD_YELLOW}All urls${NC}(${RED}$all_urls_count${NC}): ${BOLD_BLUE}$all_urls_path${NC}"

    all_extension_urls_path=$base_dir/all_extension_urls.txt
    all_extension_urls_count=$(cat $base_dir/all_extension_urls.txt | wc -l)
    echo -e "${BOLD_YELLOW}All extension urls${NC}(${RED}$all_extension_urls_count${NC}): ${BOLD_BLUE}$all_extension_urls_path${NC}"

    all_param_urls_path=$base_dir/all_urls_params.txt
    all_param_urls_count=$(cat $base_dir/all_urls_params.txt | wc -l)
    echo -e "${BOLD_YELLOW}All param urls${NC}(${RED}$all_param_urls_count${NC}): ${BOLD_BLUE}$all_param_urls_path${NC}"

    chmod -R 777 $main_dir

    exit 0
fi
