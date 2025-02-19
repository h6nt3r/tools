#!/usr/bin/env bash

# Function to display usage message
display_usage() {
    echo "Usage:"
    echo "     $0 -s http://example.com"
    echo ""
    echo "Options:"
    echo "  -h               Display this help message"
    echo "  -u               Single url scan"
    echo "  -f               List of urls scan"
    echo "  -o               Optional, save output to file"
    echo ""
    echo "Required Tools:"
    echo "              https://github.com/Emoe/kxss"
    exit 0
}

# Initialize output_file as empty string
output_file=""

while getopts ":hu:f:o:" opt; do
    case $opt in
        h)  display_usage
            exit 0
            ;;
        u)  single_url="$OPTARG"
            ;;
        f)  url_file="$OPTARG"
            ;;
        o)  output_file="$OPTARG"
            ;;
        \?) echo "Invalid option -$OPTARG" >&2
            display_usage
            exit 1
            ;;
    esac
done

if [[ -z "$single_url" && -z "$url_file" ]]; then
    echo "Error: Please provide either a URL with -u or a file with -f."
    display_usage
    exit 1
fi

if [[ -n "$single_url" ]]; then
    if [ -z "$single_url" ]; then
        echo "Error: URL must be provided for -u option."
        exit 1
    fi
    if [ -n "$output_file" ]; then
        echo "$single_url" | kxss | tee "$output_file"
        echo "Output saved to $output_file"
    else
        echo "$single_url" | kxss
    fi
elif [[ -n "$url_file" ]]; then
    if [ ! -f "$url_file" ]; then
        echo "Error: File $url_file does not exist or is not a regular file."
        exit 1
    fi
    if [ -n "$output_file" ]; then
        cat "$url_file" | kxss | tee "$output_file"
        echo "Output saved to $output_file"
    else
        cat "$url_file" | kxss
    fi
fi