#!/bin/bash
echo "Backing up WSL"
# Function to print three loading dots without new lines
function print_loading_dots() {
    local delay=0.5
    for _ in {1..3}; do
        echo -n "."
        sleep "$delay"
    done
}

# Execute the target .sh file in the background
/home/peacesea/.wsl_backup_body.sh &

# Print loading dots on the same line while the target .sh file is running
while ps | grep $! > /dev/null; do
    print_loading_dots
    echo -ne "\r\033[K"  # Move the cursor to the beginning and clear the line
done

echo    # Move to the next line after the while loop completes
echo "WSL has been backed up"
