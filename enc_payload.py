#!/usr/bin/env python3
import argparse
import urllib.parse
import base64
import hashlib
import sys
import html
import random
import base58  # pip install base58
import quopri  # pip install quopri
from termcolor import colored

MORSE_DICT = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..',
    'E': '.',  'F': '..-.', 'G': '--.',  'H': '....',
    'I': '..', 'J': '.---', 'K': '-.-',  'L': '.-..',
    'M': '--', 'N': '-.',   'O': '---',  'P': '.--.',
    'Q': '--.-','R': '.-.', 'S': '...',  'T': '-',
    'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--','Z': '--..',
    '0': '-----','1': '.----','2': '..---','3': '...--',
    '4': '....-','5': '.....','6': '-....','7': '--...',
    '8': '---..','9': '----.',
    '&': '.-...', "'": '.----.', '@': '.--.-.', ')': '-.--.-',
    '(': '-.--.', ':': '---...', ',': '--..--', '=': '-...-',
    '!': '-.-.--', '.': '.-.-.-', '-': '-....-', '+': '.-.-.',
    '"': '.-..-.', '?': '..--..', '/': '-..-.', ' ': '/'
}

output_lines = []

def url_encode(payload, times):
    for _ in range(times):
        payload = urllib.parse.quote(payload)
    return payload

def base64_encode(payload, times):
    for _ in range(times):
        payload = base64.b64encode(payload.encode()).decode()
    return payload

def base32_encode(payload, times):
    for _ in range(times):
        payload = base64.b32encode(payload.encode()).decode()
    return payload

def base58_encode(payload, times):
    for _ in range(times):
        payload = base58.b58encode(payload.encode()).decode()
    return payload

def hex_encode(payload, times):
    for _ in range(times):
        payload = ''.join(f'%{hex(ord(c))[2:].zfill(2)}' for c in payload)
    return payload

def unicode_encode(payload, times):
    for _ in range(times):
        payload = ''.join(f'\\u{ord(c):04x}' for c in payload)
    return payload

def binary_encode(payload, times):
    for _ in range(times):
        payload = ' '.join(format(ord(c), '08b') for c in payload)
    return payload

def obfuscate_payload(payload, times):
    for _ in range(times):
        payload = '+'.join([f'String.fromCharCode({ord(c)})' for c in payload])
    return payload

def html_escape_basic(payload, times):
    for _ in range(times):
        payload = html.escape(payload)
    return payload

def html_escape_fully(payload, times):
    for _ in range(times):
        payload = ''.join(f'&#{ord(c)};' for c in payload)
    return payload

def rot13_encode(payload, times):
    for _ in range(times):
        payload = payload.translate(str.maketrans(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
            "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm"
        ))
    return payload

def morse_encode(payload, times):
    for _ in range(times):
        payload = ' '.join(MORSE_DICT.get(c.upper(), '') for c in payload)
    return payload

def punycode_encode(payload, times):
    for _ in range(times):
        try:
            parts = payload.split('.')
            payload = '.'.join(['xn--' + part.encode('punycode').decode('ascii') for part in parts])
        except Exception:
            payload = 'Error encoding as Punycode'
    return payload

def ascii85_encode(payload, times):
    for _ in range(times):
        payload = base64.a85encode(payload.encode()).decode()
    return payload

# Hash functions
def md5_encode(payload, times):
    for _ in range(times):
        payload = hashlib.md5(payload.encode()).hexdigest()
    return payload

def md4_encode(payload, times):
    for _ in range(times):
        payload = hashlib.new('md4', payload.encode()).hexdigest()
    return payload

def sha1_encode(payload, times):
    for _ in range(times):
        payload = hashlib.sha1(payload.encode()).hexdigest()
    return payload

def sha256_encode(payload, times):
    for _ in range(times):
        payload = hashlib.sha256(payload.encode()).hexdigest()
    return payload

def sha384_encode(payload, times):
    for _ in range(times):
        payload = hashlib.sha384(payload.encode()).hexdigest()
    return payload

def sha512_encode(payload, times):
    for _ in range(times):
        payload = hashlib.sha512(payload.encode()).hexdigest()
    return payload

# String Case Transformation Functions
def upper_case(payload, times):
    for _ in range(times):
        payload = payload.upper()
    return payload

def lower_case(payload, times):
    for _ in range(times):
        payload = payload.lower()
    return payload

def swap_case(payload, times):
    for _ in range(times):
        payload = payload.swapcase()
    return payload

def capitalize(payload, times):
    for _ in range(times):
        payload = payload.capitalize()
    return payload

def alt_caps(payload, times):
    for _ in range(times):
        payload = ''.join([c.upper() if i % 2 == 0 else c.lower() for i, c in enumerate(payload)])
    return payload

def upper_camel_case(payload, times):
    for _ in range(times):
        payload = ''.join(word.capitalize() for word in payload.split())
    return payload

def lower_camel_case(payload, times):
    for _ in range(times):
        payload = payload[0].lower() + ''.join(word.capitalize() for word in payload[1:].split())
    return payload

def upper_snake_case(payload, times):
    for _ in range(times):
        payload = '_'.join(payload.split()).upper()
    return payload

def lower_snake_case(payload, times):
    for _ in range(times):
        payload = '_'.join(payload.split()).lower()
    return payload

def upper_kebab_case(payload, times):
    for _ in range(times):
        payload = '-'.join(payload.split()).upper()
    return payload

def lower_kebab_case(payload, times):
    for _ in range(times):
        payload = '-'.join(payload.split()).lower()
    return payload

# New Encodings:
def unicode_escape(payload, times):
    for _ in range(times):
        payload = ''.join(f'\\u{ord(c):04x}' for c in payload)
    return payload

def program_string(payload, times):
    for _ in range(times):
        payload = ''.join([f"String.fromCharCode({ord(c)})+" for c in payload])[:-1]
    return payload

def quoted_printable_encode(payload, times):
    for _ in range(times):
        payload = quopri.encodestring(payload.encode()).decode()
    return payload

def half_width(payload, times):
    half_width_map = {
        'Ａ': 'A', 'Ｂ': 'B', 'Ｃ': 'C', 'Ｄ': 'D', 'Ｅ': 'E', 'Ｆ': 'F',
        'Ｇ': 'G', 'Ｈ': 'H', 'Ｉ': 'I', 'Ｊ': 'J', 'Ｋ': 'K', 'Ｌ': 'L',
        'Ｍ': 'M', 'Ｎ': 'N', 'Ｏ': 'O', 'Ｐ': 'P', 'Ｑ': 'Q', 'Ｒ': 'R',
        'Ｓ': 'S', 'Ｔ': 'T', 'Ｕ': 'U', 'Ｖ': 'V', 'Ｗ': 'W', 'Ｘ': 'X',
        'Ｙ': 'Y', 'Ｚ': 'Z', '０': '0', '１': '1', '２': '2', '３': '3',
        '４': '4', '５': '5', '６': '6', '７': '7', '８': '8', '９': '9'
    }
    for _ in range(times):
        payload = ''.join([half_width_map.get(c, c) for c in payload])
    return payload

def full_width(payload, times):
    full_width_map = {
        'A': 'Ａ', 'B': 'Ｂ', 'C': 'Ｃ', 'D': 'Ｄ', 'E': 'Ｅ', 'F': 'Ｆ',
        'G': 'Ｇ', 'H': 'Ｈ', 'I': 'Ｉ', 'J': 'Ｊ', 'K': 'Ｋ', 'L': 'Ｌ',
        'M': 'Ｍ', 'N': 'Ｎ', 'O': 'Ｏ', 'P': 'Ｐ', 'Q': 'Ｑ', 'R': 'Ｒ',
        'S': 'Ｓ', 'T': 'Ｔ', 'U': 'Ｕ', 'V': 'Ｖ', 'W': 'Ｗ', 'X': 'Ｘ',
        'Y': 'Ｙ', 'Z': 'Ｚ', '0': '０', '1': '１', '2': '２', '3': '３',
        '4': '４', '5': '５', '6': '６', '7': '７', '8': '８', '9': '９'
    }
    for _ in range(times):
        payload = ''.join([full_width_map.get(c, c) for c in payload])
    return payload

def print_encoded(label, encoded, times, to_file):
    count = f"({times})"
    output = f"{label}{count}: {encoded}"
    output_lines.append(output)
    if not to_file:
        count_colored = colored(count, "red")
        result_colored = colored(encoded, "green")
        print(f"{label}{count_colored}: {result_colored}")

def null_byte_encode(payload, times):
    """
    Insert the null byte (%00) into the payload `times` times at random positions.
    """
    for _ in range(times):
        # Choose a random index in the payload
        index = random.randint(0, len(payload))
        # Insert the null byte (%00) at the chosen position
        payload = payload[:index] + '%00' + payload[index:]
    return payload

def plus_space_bypass_encode(payload, times):
    """
    Replace spaces with the '+' sign in the payload `times` times.
    """
    for _ in range(times):
        payload = payload.replace(' ', '+')
    return payload

def process_payload(payload, times, to_file=False):
    # Add space bypass encoding (+ sign) based on the number of times (-t value)
    print_encoded("Space Bypass", plus_space_bypass_encode(payload, times), times, to_file)
    # Other encoding methods
    print_encoded("Null Byte", null_byte_encode(payload, times), times, to_file)
    print_encoded("Url encoding", url_encode(payload, times), times, to_file)
    print_encoded("Base64", base64_encode(payload, times), times, to_file)
    print_encoded("Base32", base32_encode(payload, times), times, to_file)
    print_encoded("Base58", base58_encode(payload, times), times, to_file)
    print_encoded("Hex", hex_encode(payload, times), times, to_file)
    print_encoded("HTML Escape(Basic)", html_escape_basic(payload, times), times, to_file)
    print_encoded("ROT13", rot13_encode(payload, times), times, to_file)
    print_encoded("Punycode", punycode_encode(payload, times), times, to_file)
    print_encoded("Ascii85", ascii85_encode(payload, times), times, to_file)
    print_encoded("MD5", md5_encode(payload, times), times, to_file)
    print_encoded("MD4", md4_encode(payload, times), times, to_file)
    print_encoded("SHA-1", sha1_encode(payload, times), times, to_file)
    print_encoded("SHA-256", sha256_encode(payload, times), times, to_file)
    print_encoded("SHA-384", sha384_encode(payload, times), times, to_file)
    print_encoded("SHA-512", sha512_encode(payload, times), times, to_file)
    print_encoded("Upper Case", upper_case(payload, times), times, to_file)
    print_encoded("Lower Case", lower_case(payload, times), times, to_file)
    print_encoded("Swap Case", swap_case(payload, times), times, to_file)
    print_encoded("Capitalize", capitalize(payload, times), times, to_file)
    print_encoded("aLtErNaTiNg CaPs", alt_caps(payload, times), times, to_file)
    print_encoded("UpperCamelCase", upper_camel_case(payload, times), times, to_file)
    print_encoded("lowerCamelCase", lower_camel_case(payload, times), times, to_file)
    print_encoded("UPPER_SNAKE_CASE", upper_snake_case(payload, times), times, to_file)
    print_encoded("lower_snake_case", lower_snake_case(payload, times), times, to_file)
    print_encoded("UPPER-KEBAB-CASE", upper_kebab_case(payload, times), times, to_file)
    print_encoded("lower-kebab-case", lower_kebab_case(payload, times), times, to_file)
    print_encoded("Quoted-printable", quoted_printable_encode(payload, times), times, to_file)
    print_encoded("Half Width", half_width(payload, times), times, to_file)
    print_encoded("Full Width", full_width(payload, times), times, to_file)


def save_to_file(filename):
    with open(filename, 'w') as f:
        f.write("\n".join(output_lines))
        print(f"Output saved to {filename}")
    sys.exit(0)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--payload', required=True, help='The payload to encode')
    parser.add_argument('-t', '--times', type=int, default=1, help='Number of times to encode the payload')
    parser.add_argument('-o', '--output', help='Output file to save results')

    args = parser.parse_args()

    payload = args.payload
    times = args.times
    to_file = False

    if args.output:
        to_file = True
        save_to_file(args.output)

    process_payload(payload, times, to_file)

if __name__ == "__main__":
    main()
