#!/bin/bash
# Set the base directory where Bug Bounty related directories are located
baseDir="/opt/BugBounty"

# Check if the base directory exists
if [[ -d "$baseDir" ]]; then
  # Iterate over each subdirectory within the base directory
  for dir in "$baseDir"/*/; do
    # Check if the roots.txt file exists in the directory
    if [[ -f "${dir}/roots.txt" ]]; then
      # Extract the program or target name from the directory name
      programName=$(basename "$dir")
      echo "Grabbing domains for $programName:"
      # Use subfinder to find subdomains from the list in roots.txt, append new results to alldomains.txt
      # Notify via notify command on completion, handling potentially large output silently
      subfinder -dL "${dir}/roots.txt" -silent | anew "$dir/alldomains.txt" | notify -silent -bulk
    else
      # Print an error message if no roots.txt file is found in the directory
      programName=$(basename "$dir")
      echo "No root domains found for $programName!"
    fi
  done
else
  # Print an error message if the specified base directory does not exist
  echo "Directory '$baseDir' does not exist."
fi
