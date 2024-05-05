#!/bin/bash
# Set the base directory where the target directories for the Bug Bounty program are stored.
baseDir="/opt/BugBounty"

# Check if the specified base directory exists to prevent errors in the script execution.
if [[ -d "$baseDir" ]]; then
  # Loop through each subdirectory within the base directory to process multiple targets.
  for dir in "$baseDir"/*/; do
    # Verify if each directory contains the 'webervers.txt' which lists URLs to be processed.
    if [[ -f "${dir}/webervers.txt" ]]; then
      # Extract the directory name to use as the identifier for the current processing batch.
      programName=$(basename "$dir")
      echo "Grabbing endpoints for $programName:"
      # Utilize 'katana' to crawl for web endpoints from URLs in 'webervers.txt'. Options used:
      # -duc: Domain unique crawl, ensuring no repeated crawling on the same domain.
      # -silent: Suppress standard output to avoid cluttering the terminal.
      # -nc: No color in output, useful for logging.
      # -jsl: JavaScript links, attempt to parse for endpoints within JS files.
      # -kf: Keep fetching, continue crawling despite failures.
      # -fx: Fix, attempt to fix malformed URLs.
      # -xhr: Include XHR requests in the crawl.
      # -ef: Exclude file extensions to focus on potentially actionable web resources.
      # 'anew' is used to append new findings to 'endpoints.txt', ensuring no duplicates.
      katana -u "${dir}/webervers.txt" -duc -silent -nc -jsl -kf -fx -xhr -ef woff,css,png,svg,jpg,woff2,jpeg,gif,svg | anew -q "${dir}/endpoints.txt"
      # Suggestion: Implement passive endpoint grabbing tools here to enhance coverage without additional traffic.
      # Improvement: Consider integrating tools for quick security checks, like reflected parameters scanning, which could streamline vulnerability assessment phases.
    else
      # If the expected 'webervers.txt' file is not found, provide feedback to the user.
      programName=$(basename "$dir")
      echo "No root domains found for $programName!"
    fi
  done
else
  # Notify the user if the initial directory check fails to confirm the presence of the base directory.
  echo "Directory '$baseDir' does not exist."
fi
