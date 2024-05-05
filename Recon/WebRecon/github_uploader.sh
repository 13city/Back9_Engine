#!/bin/bash
# Script to upload or update a Markdown report on GitHub and, upon success, trigger a Discord notification.

# GitHub configuration variables
GITHUB_REPO="13city/the_back_9"
GITHUB_TOKEN=""
GITHUB_BRANCH="main"
discordNotifier="/root/Builds/BugBounty/Recon/WebRecon/discord_notifier.sh"

upload_report() {
  local report_path="$1"
  local program_name="$2"
  
  # Extract filename from the report path
  local filename=$(basename "$report_path")
  # Define the target path on GitHub
  local target_path="reports/${program_name}/${filename}"
  # Construct the GitHub API URL for the target path
  local api_url="https://api.github.com/repos/$GITHUB_REPO/contents/$target_path"

  # Attempt to get the SHA of an existing file to determine if this will be an update
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$api_url" | jq -r '.sha // empty')

  # Encode the report content in Base64 format
  local content_base64=$(base64 -w 0 "$report_path")
  
  # Prepare the JSON payload for the GitHub API request
  local json_payload=$(jq -n --arg path "$target_path" \
                                --arg message "Report update for $program_name" \
                                --arg content "$content_base64" \
                                --arg sha "$sha" \
                                --arg branch "$GITHUB_BRANCH" \
                                '{message: $message, content: $content, sha: $sha, branch: $branch}')

  # Make the API request to upload or update the report
  local response=$(curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" -d "$json_payload" "$api_url" -o response.json -w "%{http_code}")

  # Check if the upload was successful
  if [[ "$response" -eq "200" ]] || [[ "$response" -eq "201" ]]; then
    local report_url=$(jq -r '.content.html_url' response.json)
    echo "Report uploaded successfully to GitHub: $report_path"
    echo "Report URL: $report_url"
    
    # Construct the message for Discord notification
    local message="📄 New report for $program_name: $report_url"
    
    # Trigger the Discord notification
    bash "$discordNotifier" "$report_path" "$message" "ReconBot" "$program_name"
  else
    echo "Failed to upload report to GitHub: $report_path"
    echo "Response code: $response"
    cat response.json
  fi

  # Clean up the temporary file
  rm -f response.json
}

# Check script arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <report_path> <program_name>"
  exit 1
fi

report_path="$1"
program_name="$2"
upload_report "$report_path" "$program_name"
