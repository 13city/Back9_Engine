#!/bin/bash

set -Eeuo pipefail

install_tool() {
    local tool_path="$1"
    local tool_name="$2"

    echo "[*] Attempting to install ${tool_name}..."

    if go install -v "${tool_path}@latest"; then
        echo "[+] Successfully installed ${tool_name}."
    else
        echo "[-] Failed to install ${tool_name}. Attempting to retry..."

        # Retry installation
        if go install -v "${tool_path}@latest"; then
            echo "[+] Successfully installed ${tool_name} on retry."
        else
            echo "[-] Failed to install ${tool_name} after retry. Please check the error messages and try manually if needed."
        fi
    fi
}

echo "[*] Starting the installation of tools..."

# DNSX
install_tool "github.com/projectdiscovery/dnsx/cmd/dnsx" "DNSX"

# Subfinder
install_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "Subfinder"

# Katana
echo "[*] Attempting to install Katana..."
if go install "github.com/projectdiscovery/katana/cmd/katana@latest"; then
    echo "[+] Successfully installed Katana."
else
    echo "[-] Failed to install Katana. Please check the error messages and try manually if needed."
fi

# Smap
install_tool "github.com/s0md3v/smap/cmd/smap" "Smap"

# HTTPX
install_tool "github.com/projectdiscovery/httpx/cmd/httpx" "HTTPX"

# Anew
install_tool "github.com/tomnomnom/anew" "Anew"

# Httprobe
echo "[*] Attempting to install Httprobe..."
if go install "github.com/tomnomnom/httprobe@latest"; then
    echo "[+] Successfully installed Httprobe."
else
    echo "[-] Failed to install Httprobe. Please check the error messages and try manually if needed."
fi

echo "[*] Tool installation process completed."
