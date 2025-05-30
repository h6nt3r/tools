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
    tools=("unfurl" "subfinder" "anew" "httpx" "urlfinder" "gau" "waybackurls" "ghauri" "iconv")

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

    echo "gau=================================="
    wget "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
    sudo tar -xvzf gau_2.2.4_linux_amd64.tar.gz
    sudo mv gau /usr/local/bin/
    sudo chmod +x /usr/local/bin/gau
    sudo rm -rf ./*
    gau -h

    echo "subfinder=================================="
    wget "https://github.com/projectdiscovery/subfinder/releases/download/v2.7.1/subfinder_2.7.1_linux_amd64.zip"
    sudo unzip subfinder_2.7.1_linux_amd64.zip
    sudo mv subfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/subfinder
    sudo rm -rf ./*
    subfinder -h

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
    cd sqlier

    echo "waybackurls=================================="
    wget "https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz"
    sudo tar -xzvf waybackurls-linux-amd64-0.1.0.tgz
    sudo mv waybackurls /usr/local/bin/
    sudo chmod +x /usr/local/bin/waybackurls
    sudo rm -rf ./*
    waybackurls -h

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


# Time based
if [[ "$1" == "-d" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls -no-subs "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=BEST --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Time based
if [[ "$1" == "-d" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls -no-subs "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=E --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Time based
if [[ "$1" == "-d" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls -no-subs "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=B --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Time based
if [[ "$1" == "-d" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls -no-subs "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=BB --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi


# Time based
if [[ "$1" == "-d" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls -no-subs "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# All sqlis
if [[ "$1" == "-l" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=BEST --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Time based
if [[ "$1" == "-l" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi


# Blind based
if [[ "$1" == "-l" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=B --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=E --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -o $base_dir/urlfinder.txt

    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    waybackurls "$domain_Without_Protocol" | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls_iso.txt

    iconv -f ISO-8859-1 -t UTF-8 $base_dir/all_params_urls_iso.txt -o $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --ignore-code=401 --level=3 --technique=BB --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi
