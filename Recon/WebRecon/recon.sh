#!/bin/bash
#set -x  # Enable debugging

# Base directory where target data is stored for recon purposes
baseDir="$HOME/Builds/BugBounty/Recon/Targets"
# Path to the Katana binary, used for endpoint grabbing
KATANA="/root/go/bin/katana"
# Path to the Smap binary, used for scanning open ports
SMAP="/root/go/bin/smap"

# Function to convert a list of domains or endpoints into a JSON format
generate_json_report() {
  local inputFile="$1"
  local outputFile="$2"
  # Using jq to transform plain text lines into a JSON array
  jq -R -s -c 'split("\n") | map(select(length > 0))' "$inputFile" > "$outputFile"
}

# Check if the base directory exists
if [[ -d "$baseDir" ]]; then
  # Loop through each subdirectory in the base directory
  for dir in "$baseDir"/*/; do
    # Convert relative path to absolute path
    dir=$(realpath "$dir")
    # Check if the directory contains a roots.txt file
    if [[ -f "${dir}/roots.txt" ]]; then
      # Extract the name of the program or target from the directory name
      programName=$(basename "$dir")
      echo "Recon for $programName:"

      # Run subfinder to find subdomains and save output
      subfinderOutput="${dir}/subfinderOutput.txt"
      subfinder -dL "${dir}/roots.txt" -silent > "$subfinderOutput"

      # Use dnsx to resolve found subdomains and save the output to a file
      resolvedDomains="${dir}/resolveddomains.txt"
      cat "$subfinderOutput" | dnsx -silent | anew "$resolvedDomains"

      # Check which domains are live using httpx and append results to a file
      liveDomains="${dir}/livedomains.txt"
      httpx -l "$resolvedDomains" -silent | anew "$liveDomains"
      # Generate a JSON report for live domains
      liveDomainsJson="${dir}/livedomains.json"
      generate_json_report "$liveDomains" "$liveDomainsJson"

      # Grab endpoints for live domains and save output
      endpointsOutput="${dir}/endpoints.txt"
      if [[ -s "$liveDomains" ]]; then
        $KATANA -l "$liveDomains" -silent | anew "$endpointsOutput"
      fi
      # Generate a JSON report for endpoints
      endpointsJson="${dir}/endpoints.json"
      generate_json_report "$endpointsOutput" "$endpointsJson"

      # Scan for open ports on resolved domains using smap and append results
      openPortsOutput="${dir}/openports.txt"
      if [[ -s "$resolvedDomains" ]]; then
        $SMAP -iL "$resolvedDomains" | anew "$openPortsOutput"
      fi
      # Generate a JSON report for open ports
      openPortsJson="${dir}/openports.json"
      generate_json_report "$openPortsOutput" "$openPortsJson"
      
    else
      # Print an error message if no roots.txt file is found
      echo "No root domains found for $programName!"
    fi
  done
else
  # Print an error message if the base directory does not exist
  echo "Directory '$baseDir' does not exist."
fi
