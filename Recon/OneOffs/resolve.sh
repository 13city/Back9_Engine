#!/bin/bash
# Define the base directory where target data is stored for the Bug Bounty program.
baseDir="/opt/BugBounty"

# Check if the specified base directory exists to ensure the script operates on a valid path.
if [[ -d "$baseDir" ]]; then
  # Iterate over each subdirectory within the base directory to handle multiple targets.
  for dir in "$baseDir"/*/; do
    # Check if the 'alldomains.txt' file exists in the directory, which contains a list of domains to resolve.
    if [[ -f "${dir}/alldomains.txt" ]]; then
      # Extract the name of the program from the directory for contextual logging.
      programName=$(basename "$dir")
      echo "Resolving domains for $programName:"
      # Use 'dnsx' to resolve domains listed in 'alldomains.txt'. The '-silent' flag suppresses extra output.
      # 'anew' appends new unique resolved domains to 'resolveddomains.txt', avoiding duplicates.
      # 'notify' sends a silent notification on completion of the task, useful for async or batch operations.
      dnsx -l "${dir}/alldomains.txt" -silent | anew "$dir/resolveddomains.txt" | notify -silent
      # Suggestion: Implement error handling to retry or log failures in domain resolution for robustness.
      # Improvement: Consider integrating rate limiting or parallel processing to optimize resolution times.
    else
      # Notify if the expected domain list file is not found, which is crucial for further processes.
      programName=$(basename "$dir")
      echo "No domains file found for $programName!"
    fi
  done
else
  # Alert the user if the base directory does not exist, preventing any further operations.
  echo "Directory '$baseDir' does not exist."
fi
