#!/bin/bash

set -Eeuo pipefail

echo "[*] Updating the system and installing necessary packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl wget tar unzip make zip

echo "[*] Removing any existing Go installation..."
sudo apt-get remove --auto-remove golang-go
sudo rm -rf /usr/local/go

GO_VERSION="1.21.3"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://dl.google.com/go/${GO_TAR}"

echo "[*] Downloading Go ${GO_VERSION}..."
wget "${GO_URL}"

echo "[*] Extracting Go archive..."
sudo tar -xvf "${GO_TAR}" -C /usr/local
rm "${GO_TAR}"

echo "[*] Setting up Go environment variables..."
echo 'export GOROOT=/usr/local/go' >> ~/.profile
echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.profile
source ~/.profile

echo "[*] Verifying Go installation..."
go version

echo "[*] Go ${GO_VERSION} installation is complete."
