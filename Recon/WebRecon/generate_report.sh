#!/bin/bash

# Define the base directory where your target directories are located
baseDir="$HOME/Builds/BugBounty/Recon/Targets"

# Define paths to other scripts
githubUploader="/root/Builds/BugBounty/Recon/WebRecon/github_uploader.sh"
discordNotifier="/root/Builds/BugBounty/Recon/WebRecon/discord_notifier.sh"
snapshotDir="$baseDir/snapshots"

# Function to parse JSON data and generate a Markdown report
generate_and_upload_report() {
  local targetDir="$1"
  local programName="$(basename "$targetDir")"
  local currentDate=$(date +%Y-%m-%d)
  local reportFile="${targetDir}/report_${programName}_${currentDate}.md"
  local snapshotFile="${snapshotDir}/${programName}_snapshot.json"
  local totalFindings=0
  local newFindings=0
  local closedFindings=0

  mkdir -p "$snapshotDir"

  echo "# Reconnaissance Report for ${programName}" > "$reportFile"
  echo "Generated on $(date '+%Y-%m-%d %H:%M:%S')." >> "$reportFile"
  echo "" >> "$reportFile"
  echo "## Executive Summary" >> "$reportFile"
  echo "This document outlines the findings from the reconnaissance phase targeting **${programName}**." >> "$reportFile"
  echo "" >> "$reportFile"

  # Compare current findings to the last snapshot and record deltas
  if [ -f "$snapshotFile" ]; then
    echo "### Changes Since Last Report" >> "$reportFile"
  fi

  # Add sections for live domains, endpoints, and open ports
  for dataType in livedomains endpoints openports; do
    local dataFile="${targetDir}/${dataType}.json"
    if [ -f "$dataFile" ]; then
      local count=$(jq '. | length' "$dataFile")
      totalFindings=$((totalFindings + count))
      echo "### ${dataType^}" >> "$reportFile"
      echo "**Total ${dataType^}: $count**" >> "$reportFile"
      # Check for changes since last run
      if [ -f "$snapshotFile" ]; then
        # Logic to calculate new and closed findings
        newFindings=$(jq --argfile newData "$dataFile" --argfile oldData "$snapshotFile" \
                          '[($newData | .[]) as $newItem | if ($oldData | index($newItem)) then empty else $newItem end] | length' )
        closedFindings=$(jq --argfile newData "$dataFile" --argfile oldData "$snapshotFile" \
                             '[($oldData | .[]) as $oldItem | if ($newData | index($oldItem)) then empty else $oldItem end] | length' )
        echo "**New ${dataType^}: $newFindings**" >> "$reportFile"
        echo "**Closed ${dataType^}: $closedFindings**" >> "$reportFile"
      fi
      jq -r '.[] | "- \(.domain) | \(.status) | \(.title)"' "$dataFile" >> "$reportFile"
    else
      echo "### ${dataType^}" >> "$reportFile"
      echo "No ${dataType^} found." >> "$reportFile"
    fi
    echo "" >> "$reportFile"
  done

  # Update the snapshot with current findings
  jq -n '{livedomains: [], endpoints: [], openports: []}' > "$snapshotFile"
  for dataType in livedomains endpoints openports; do
    local dataFile="${targetDir}/${dataType}.json"
    if [ -f "$dataFile" ]; then
      jq --argfile data "$dataFile" '.[$dataType] = $data | .[$dataType]' "$snapshotFile" > "${snapshotFile}.tmp" \
        && mv "${snapshotFile}.tmp" "$snapshotFile"
    fi
  done

  # Notify via Discord
  local reportURL=$(bash "$githubUploader" "$reportFile" "$programName" | grep -Po '(?<=Report URL: ).*')
  local summaryMessage="🔍 **Reconnaissance Summary for ${programName}**\n"
  summaryMessage+="Total findings: **${totalFindings}**\n"
  summaryMessage+="New findings: **${newFindings}**\n"
  summaryMessage+="Closed findings: **${closedFindings}**\n"
  summaryMessage+="Report generated on $(date '+%Y-%m-%d %H:%M:%S'). Check the detailed report [here](${reportURL})."
  bash "$discordNotifier" "$targetDir" "$summaryMessage" "ReconBot" "$programName"
}

# Iterate over each target directory and generate/upload a report
for targetDir in "$baseDir"/*/; do
  generate_and_upload_report "$targetDir"
done
