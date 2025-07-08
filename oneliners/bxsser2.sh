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
    tools=( "bxsser" "urlfinder" "gau" "waybackurls" "google-chrome" "uro" "unfurl" "xargs" "katana" "unzip" "reflection")

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
    mkdir -p --mode=777 bxsser2

    cd bxsser2
    sudo apt install unzip -y
    echo "bxsser=================================="
    cd /opt/ && sudo git clone https://github.com/h6nt3r/bxsser.git && cd bxsser/
    sudo chmod +x ./*
    sudo pip3 install -r requirements.txt --break-system-packages
    cd
    sudo ln -sf /opt/bxsser/bxsser.py /usr/local/bin/bxsser
    bxsser -h


    cd bxsser2
    echo "urlfinder===================================="
    wget "https://github.com/projectdiscovery/urlfinder/releases/download/v0.0.3/urlfinder_0.0.3_linux_amd64.zip"
    sudo unzip urlfinder_0.0.3_linux_amd64.zip
    sudo mv urlfinder /usr/local/bin/
    sudo chmod +x /usr/local/bin/urlfinder
    urlfinder -h
    sudo rm -rf ./*
    cd

    cd bxsser2
    echo "google-chrome===================================="
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt --fix-broken install -y
    sudo apt install ./google-chrome-stable*.deb -y
    sudo rm -rf ./*
    cd

    cd bxsser2
    echo "gau===================================="
    wget "https://github.com/lc/gau/releases/download/v2.2.4/gau_2.2.4_linux_amd64.tar.gz"
    sudo tar -xzf gau_2.2.4_linux_amd64.tar.gz
    sudo mv gau /usr/local/bin/
    gau -h
    sudo rm -rf ./*
    cd

    cd bxsser2
    echo "unfurl=================================="
    wget "https://github.com/tomnomnom/unfurl/releases/download/v0.4.3/unfurl-linux-amd64-0.4.3.tgz"
    sudo tar -xzvf unfurl-linux-amd64-0.4.3.tgz
    sudo mv unfurl /usr/local/bin/
    sudo chmod +x /usr/local/bin/unfurl
    unfurl -h
    sudo rm -rf ./*
    cd

    cd bxsser2
    echo "katana=================================="
    wget "https://github.com/projectdiscovery/katana/releases/download/v1.1.0/katana_1.1.0_linux_amd64.zip"
    unzip katana_1.1.0_linux_amd64.zip
    sudo mv katana /usr/local/bin/
    sudo rm -rf ./*
    katana -h
    cd

    cd bxsser2
    echo "waybackurls=================================="
    wget "https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz"
    sudo tar -xzvf waybackurls-linux-amd64-0.1.0.tgz
    sudo mv waybackurls /usr/local/bin/
    sudo chmod +x /usr/local/bin/waybackurls
    sudo rm -rf ./*
    waybackurls -h
    cd

    cd bxsser2
    cd /opt/ && sudo git clone https://github.com/h6nt3r/reflection.git
    cd
    sudo chmod +x /opt/reflection/*.py
    sudo ln -sf /opt/reflection/reflector.py /usr/local/bin/reflection
    sudo apt install dos2unix -y
    sudo dos2unix /opt/reflection/reflector.py
    reflection -h
    cd

    echo "uro===================================="
    cd /opt/ && sudo git clone https://github.com/s0md3v/uro.git && cd uro/
    sudo chmod +x ./*
    sudo python3 setup.py install
    cd
    uro -h

    echo "Downloading payloads===================================="
    wget "https://raw.githubusercontent.com/h6nt3r/collection_payloads/refs/heads/main/xss/blindxssreport.txt"
    sudo rm -rf blindxssreport.txt.*

    sudo rm -rf bxsser2
    
    exit 0
fi

# Single domain
# bxss vulnerability
if [ "$1" == "-u" ]; then
    echo "Single url==============="
    domain=$2
    bxsser -u "$domain" -p blindxssreport.txt -t 4
    exit 0
fi

# bxss vulnerability
if [ "$1" == "-d" ]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/single_domain/blindxss"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -fs fqdn -o $base_dir/urlfinder.txt

    cat "$domain_Without_Protocol" | gau --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat "$domain_Without_Protocol" | waybackurls -no-subs | tee $base_dir/waybackurls.txt

    katana -u "$domain_Without_Protocol" -fs fqdn -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o $base_dir/katana.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt $base_dir/katana.txt | sed 's/:[0-9]\+//' | uro | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|xml)($|\s|\?|&|#|/|\.)" | sort -u | tee $base_dir/all_urls.txt

    bxsser -f $base_dir/all_urls.txt -p blindxssreport.txt

    chmod -R 777 $main_dir
    exit 0

fi

# Multi domain
# bxss vulnerability
if [ "$1" == "-l" ]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | unfurl -u domains)
    main_dir="bug_bounty/$domain_Without_Protocol"
    base_dir="$main_dir/Multi_domain/blindxss"

    mkdir -p $main_dir

    urlfinder -all -d "$domain_Without_Protocol" -t 20 -o $base_dir/urlfinder.txt

    cat "$domain_Without_Protocol" | gau --subs --providers wayback,commoncrawl,otx,urlscan --verbose --o $base_dir/gau.txt

    cat "$domain_Without_Protocol" | waybackurls | tee $base_dir/waybackurls.txt

    katana -u "$domain_Without_Protocol" -rl 170 -timeout 5 -retry 2 -aff -d 4 -duc -ps -pss waybackarchive,commoncrawl,alienvault -o $base_dir/katana.txt

    cat $base_dir/urlfinder.txt $base_dir/gau.txt $base_dir/waybackurls.txt $base_dir/katana.txt | sed 's/:[0-9]\+//' | iconv -f ISO-8859-1 -t UTF-8 | uro | grep -a "[=&]" | grep -aiEv "\.(css|ico|woff|woff2|svg|ttf|eot|png|jpg|js|json|pdf|xml)($|\s|\?|&|#|/|\.)" | sort -u | tee $base_dir/all_urls.txt

    cat $base_dir/all_urls.txt | bxss -t -X GET,POST -pf blindxssreport.txt

    chmod -R 777 $main_dir
    exit 0
fi
