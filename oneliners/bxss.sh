#!/usr/bin/env bash

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
    tools=( "anew" "qsreplace" "bxss" "gau")

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
    echo "bxss=================================="
    go install -v github.com/ethicalhackingplayground/bxss/v2/cmd/bxss@latest
    echo "gau===================================="
    go install github.com/lc/gau/v2/cmd/gau@latest
    mv ~/go/bin/* /usr/local/bin/
    exit 0
fi


# Single domain
# bxss vulnerability
if [ "$1" == "-u" ]; then
    echo "Single URL==============="
    url=$2
    echo "$url" | bxss -parameters -payloadFile bxss.txt
fi

# bxss vulnerability
if [ "$1" == "-d" ]; then
    echo "Single Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')
    gau "$domain_Without_Protocol" --providers wayback,commoncrawl,otx,urlscan | grep -avE '\.js($|\s|\?|&|#|/|\.)|\.json($|\s|\?|&|#|/|\.)\.css($|\s|\?|&|#|/|\.)' | qsreplace "BXSS" | grep -a "BXSS" | anew | bxss -parameters -payloadFile bxss.txt
fi

# Multi domain
# bxss vulnerability
if [ "$1" == "-l" ]; then
    echo "Multi Domain==============="
    domain_Without_Protocol=$(echo "$2" | sed 's,http://,,;s,https://,,;s,www\.,,')
    gau "$domain_Without_Protocol" --subs --providers wayback,commoncrawl,otx,urlscan | grep -avE '\.js($|\s|\?|&|#|/|\.)|\.json($|\s|\?|&|#|/|\.)\.css($|\s|\?|&|#|/|\.)' | qsreplace "BXSS" | grep -a "BXSS" | anew | bxss -parameters -payloadFile bxss.txt
fi