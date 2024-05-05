#!/bin/bash

# Set the base directory that contains subdirectories for each target within the Bug Bounty program.
baseDir="/opt/BugBounty"

# Ensure the base directory exists before proceeding to avoid unnecessary errors.
if [[ -d "$baseDir" ]]; then
  # Iterate over each subdirectory within the base directory to process different targets.
  for dir in "$baseDir"/*/; do
    # Verify the presence of the 'resolveddomains.txt' in each subdirectory, which contains resolved domain names.
    if [[ -f "${dir}/resolveddomains.txt" ]]; then
      # Extract and display the name of the current program for better tracking and output clarity.
      programName=$(basename "$dir")
      echo "Finding web servers for $programName:"
      # Use httpx to check the liveliness of each domain in 'resolveddomains.txt'.
      # Configure httpx with a timeout of 75 seconds and silent mode to minimize output verbosity.
      # Pipe results into 'anew' to append unique live domains to 'livedomains.txt' and avoid duplicates.
      # Use 'notify' to send a silent notification upon completion, useful for asynchronous operations.
      httpx -l "${dir}/resolveddomains.txt" -t 75 -silent | anew "${dir}/livedomains.txt" | notify -silent
      echo "" # Adds a blank line for better readability in terminal output.
      # Suggestion: Consider adding a progress indicator or logging mechanism to track the status of each operation.
      # Improvement: Integrate error handling to retry failed requests or log unsuccessful operations for review.
    else
      # Notify the user if no resolved domains are found in the subdirectory, indicating a potential issue in the previous steps.
      programName=$(basename "$dir")
      echo "No resolved domains found for $programName"
    fi
  done
else
  # Alert the user if the base directory does not exist, indicating a fundamental configuration error.
  echo "Directory '$baseDir' does not exist."
fi
