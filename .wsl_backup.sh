#!/bin/bash

# Function to display a pop-up message if the partition is running out of space
function display_popup() {
    zenity --warning --text="Warning: Some partitions are running out of space.\nPlease clear up space before proceeding with the backup."
}

# Function to display a persistent notification
function display_notification() {
    echo "Backup halted. Some partitions are running out of space."
    echo "Press Enter to continue."
    read -r
}

# Function to print three blinking dots without new lines
function print_blinking_dots() {
    while true; do
        echo -ne "."
        sleep 0.5
        echo -ne "\b\b\b   \b\b\b"
        sleep 0.5
    done
}

# Function to check available and total space for a partition using the 'df' command and 'awk' for parsing
function check_partition_space() {
    local partition=$1
    local space_info=$(df -BG "$partition" | awk 'NR==2 {print $3, $4}')
    local available_space_gb=$(echo "$space_info" | awk '{print $1}' | tr -d 'G')
    local total_space_gb=$(echo "$space_info" | awk '{print $2}' | tr -d 'G')
    echo "$available_space_gb $total_space_gb"
}

# Function to convert a size in bytes to GB
function bytes_to_gb() {
    local size_in_bytes=$1
    local size_in_gb=$((size_in_bytes / 1024 / 1024 / 1024))
    echo "$size_in_gb"
}

# Backup directory
DESTINATION="/mnt/c/Users/roman/WSL_backups"

# Create a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Threshold percentages for each partition (as percentages of total space)
THRESHOLD_C_PERCENTAGE=80
THRESHOLD_D_PERCENTAGE=70

# Define variables for C and D partitions
PARTITION_C="/mnt/c"
PARTITION_D="/mnt/d"

# Get available and total space for each partition
AVAILABLE_SPACE_GB=(
    $(check_partition_space "$PARTITION_C")  # Windows C Drive
    $(check_partition_space "$PARTITION_D")  # Windows D Drive
)

# Get total space for each partition
TOTAL_SPACE_GB=(
    $(check_partition_space "$PARTITION_C")  # Windows C Drive
    $(check_partition_space "$PARTITION_D")  # Windows D Drive
)

# Calculate the threshold values in GB
THRESHOLD_C_GB=$((TOTAL_SPACE_GB[0] * THRESHOLD_C_PERCENTAGE / 100))
THRESHOLD_D_GB=$((TOTAL_SPACE_GB[1] * THRESHOLD_D_PERCENTAGE / 100))

# Execute the target .sh file (wsl_backup_body.sh) to get the estimated backup size in dry-run mode
WSL_BACKUP_SIZE_BYTES=$(bash /home/peacesea/.wsl_backup_body.sh --dry-run | awk '/WSL backup size:/ {print $NF}')
WSL_BACKUP_SIZE_GB=$(bytes_to_gb "$WSL_BACKUP_SIZE_BYTES")

# Elaborate display of partition memory and other information
echo "=============================="
echo "  Partition Memory Overview"
echo "=============================="
echo "Windows C Drive (mnt/c):"
echo "   Available Space: ${AVAILABLE_SPACE_GB[0]} GB"
echo "   Total Space: ${TOTAL_SPACE_GB[0]} GB"
echo "   Threshold Space: $THRESHOLD_C_GB GB"
if ((AVAILABLE_SPACE_GB[0] < WSL_BACKUP_SIZE_GB)) || ((AVAILABLE_SPACE_GB[0] < THRESHOLD_C_GB)); then
    echo "   Status: Running out of space"
else
    echo "   Status: Sufficient space"
fi
echo "------------------------------"
echo "Windows D Drive (mnt/d):"
echo "   Available Space: ${AVAILABLE_SPACE_GB[1]} GB"
echo "   Total Space: ${TOTAL_SPACE_GB[1]} GB"
echo "   Threshold Space: $THRESHOLD_D_GB GB"
if ((AVAILABLE_SPACE_GB[1] < WSL_BACKUP_SIZE_GB)) || ((AVAILABLE_SPACE_GB[1] < THRESHOLD_D_GB)); then
    echo "   Status: Running out of space"
else
    echo "   Status: Sufficient space"
fi
echo "------------------------------"
echo "WSL (Home Directory):"
echo "   Available Space: $WSL_BACKUP_SIZE_GB GB"
echo "   Threshold Space: Not applicable"
echo "=============================="

# Display the pop-up message for partition space check
display_popup

# Check the trigger condition (available_space_gb < required_space_gb)
if ((AVAILABLE_SPACE_GB[0] < WSL_BACKUP_SIZE_GB)) || ((AVAILABLE_SPACE_GB[1] < WSL_BACKUP_SIZE_GB)); then
    trigger_condition=true
else
    trigger_condition=false
fi

# If the trigger condition is true, display a persistent notification and halt the backup
if "$trigger_condition" = true; then
    display_notification
else
    # If the trigger condition is false, execute the actual tar command to perform the backup
    bash /home/peacesea/.wsl_backup_body.sh
    
    # Print blinking dots while the backup process is running
    print_blinking_dots
fi
wsl_backup_body.sh:

bash
Copy code
#!/bin/bash

# Backup directory
DESTINATION="/mnt/c/Users/roman/WSL_backups"

# Create a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Check if the script is running in dry-run mode
if [[ "$1" == "--dry-run" ]]; then
    # Print the estimated WSL backup size without actually performing the backup
    WSL_BACKUP_SIZE_GB=$(du -sh --exclude="$DESTINATION" "$HOME" | awk '{print $1}')
    echo "WSL backup size: $WSL_BACKUP_SIZE_GB GB"
else
    # Compress the WSL home directory (excluding the backup directory itself) and save it to the backup location
    tar -czf "$DESTINATION/$TIMESTAMP.tar.gz" --exclude="$DESTINATION" --directory="$HOME" .
    # Optionally, you can add additional backup commands or exclude specific files/directories using the --exclude flag in the tar command.
fi
Please use these updated scripts with all the functions, logic, and content included. If you have any more questions or need further assistance, feel free to ask!





