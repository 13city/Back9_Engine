#!/bin/bash

# Define directories and script paths
baseDir="$HOME/Builds/BugBounty/Recon/Targets"
reconScript="/root/Builds/BugBounty/Recon/WebRecon/recon.sh"
generateReportScript="/root/Builds/BugBounty/Recon/WebRecon/generate_report.sh"
discordNotifierScript="/root/Builds/BugBounty/Recon/WebRecon/discord_notifier.sh"

# Setup for centralized logging outside the WebRecon directory
logDir="$HOME/Builds/BugBounty/Recon/Logs" # Updated path to place logs outside WebRecon
logFile="${logDir}/recon_pipe_$(date +%Y-%m-%d).log"

# Ensure logging directory exists
mkdir -p "$logDir"

# Logging function with expanded details and color coding
log() {
    local severity=$1; shift
    local message=$@
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color

    # Define color codes and severity levels
    case $severity in
        DEBUG) color="\033[0;36m";;  # Cyan for debug
        INFO) color="\033[0;32m";;   # Green for info
        WARN) color="\033[0;33m";;   # Yellow for warnings
        ERROR) color="\033[0;31m";;  # Red for errors
        *) color="\033[0m";;         # Default no color
    esac

    # Print to console with color and append to log file
    echo -e "${color}${timestamp} [$severity] - $message\033[0m" | tee -a "$logFile"
}

# Check script existence
check_script_existence() {
    if [ ! -f "$1" ]; then
        log ERROR "Script $1 not found. Please check the path and try again."
        exit 1
    fi
}

# Log start of the script
log INFO "Starting the Recon Pipe process..."

# Check existence of required scripts
check_script_existence "$reconScript"
check_script_existence "$generateReportScript"
check_script_existence "$discordNotifierScript"

# Run the reconnaissance script
log INFO "Executing the reconnaissance script: $reconScript"
if output=$(bash "$reconScript" 2>&1); then
    log INFO "Reconnaissance script completed successfully."
else
    log ERROR "Reconnaissance script failed with output: $output"
    echo "$output" >> "$logFile"  # Log detailed output for diagnosis
    exit 1
fi

# Run the report generation script
log INFO "Executing the report generation script: $generateReportScript"
if output=$(bash "$generateReportScript" 2>&1); then
    log INFO "Report generation script completed successfully."
else
    log ERROR "Report generation script failed with output: $output"
    echo "$output" >> "$logFile"  # Log detailed output for diagnosis
    exit 1
fi

# Prepare and run the Discord notifier script for each target
for targetDir in "$baseDir"/*/; do
    programName=$(basename "$targetDir")
    findingsSummary="PLACEHOLDER_FOR_FINDINGS"  # Placeholder; should be replaced with actual summary data.

    log INFO "Executing the Discord notification script for $programName."
    if output=$(bash "$discordNotifierScript" "$targetDir" "$programName" "$findingsSummary" 2>&1); then
        log INFO "Discord notification script completed successfully for $programName."
    else
        log ERROR "Discord notification script failed for $programName with output: $output"
        echo "$output" >> "$logFile"  # Log detailed output for diagnosis
        # Continuing with other notifications if one fails
    fi
done

# Final message
log INFO "Recon Pipe workflow completed. All processes executed successfully."
