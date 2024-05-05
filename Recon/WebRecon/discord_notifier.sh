#!/bin/bash

# Define the base directory where your target directories are located
baseDir="$HOME/Builds/BugBounty/Recon/Targets"

# Function to log messages with timestamp
log() {
  local level="$1"
  local message="$2"
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message"
}

# Function to generate a summary message
generate_summary_message() {
  local report_url="$1"
  local program_name="$2"
  local findings_summary="$3"

  local summary="🔍 **Reconnaissance Summary for ${program_name}**\n${findings_summary}\n\n[View the full report here](${report_url})"
  echo "$summary"
}

# Function to send the message to Discord using a webhook
send_to_discord() {
  local program_name="$1"
  local summary_message="$2"
  
  local webhook_url_file="${baseDir}/webhook.txt" # Corrected path

  # Validate that the webhook URL file exists
  if [[ ! -f "$webhook_url_file" ]]; then
    log "ERROR" "Webhook URL file not found at ${webhook_url_file}"
    return 1
  fi

  local webhook_url
  webhook_url=$(<"$webhook_url_file")

  # Validate that webhook URL is not empty
  if [[ -z "$webhook_url" ]]; then
    log "ERROR" "Webhook URL is empty"
    return 1
  fi

  # Prepare JSON payload for Discord
  local json_payload
  json_payload=$(jq -n \
    --arg content "$summary_message" \
    --argjson embeds "[{\"title\": \"Summary Report for $program_name\", \"description\": \"$summary_message\", \"color\": 3447003}]" \
    '{content: $content, embeds: $embeds}' 2> /dev/null)

  # Check for successful JSON creation
  if [[ $? -ne 0 ]]; then
    log "ERROR" "Failed to create JSON payload for Discord"
    return 1
  fi

  # Send the payload to Discord
  local response
  response=$(curl -s -H "Content-Type: application/json" -X POST -d "$json_payload" "$webhook_url")

  # Check for successful Discord post
  if [[ $? -ne 0 ]]; then
    log "ERROR" "Failed to send data to Discord"
    echo "Response from Discord: $response"
    return 1
  else
    log "INFO" "Successfully sent data to Discord"
  fi
}

# Main execution logic
if [[ $# -lt 3 ]]; then
  log "ERROR" "Usage: $0 <program_name> <findings_summary> <report_url>"
  exit 1
fi

program_name="$1"
findings_summary="$2"
report_url="$3"

# Generate the summary message
summary_message=$(generate_summary_message "$report_url" "$program_name" "$findings_summary")

# Send the summary message to Discord
send_to_discord "$program_name" "$summary_message"

# Check final status and exit accordingly
if [[ $? -eq 0 ]]; then
  log "INFO" "Discord notification completed successfully"
  exit 0
else
  log "ERROR" "Discord notification failed"
  exit 1
fi
