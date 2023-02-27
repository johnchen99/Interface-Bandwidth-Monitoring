## CRON job (cron -e):
# */5 * * * * /root/interface_monitor.sh

#!/bin/bash

OUTPUT_DIR="/root/bandwidth_interface"
DAYS_TO_KEEP=30
INTERVAL=300 # 5 minutes

# # Prevent multiple instance
# SCRIPT_LOCK="$OUTPUT_DIR/.lock"
# # Check if the script running 
# if [ -f "$SCRIPT_LOCK" ]; then
#     echo "Lock file exists, exiting"
#     exit 1
# fi
# # Else, create lock file
# touch "$SCRIPT_LOCK"

# Set error handling
set -e

# while true; do
# Get the network interface
NETWORK_INTERFACE=$(ip route get 8.8.8.8 | awk 'NR==2 {print $1}' RS="dev")

# Create the output directory if it doesn't exist
if [ ! -d $OUTPUT_DIR ]; then
    mkdir -p -m 755 $OUTPUT_DIR
fi
OUTPUT_DIR=$OUTPUT_DIR/$(date +%Y-%m)
if [ ! -d $OUTPUT_DIR ]; then
    mkdir -p -m 755 $OUTPUT_DIR
fi

# Generate a unique filename based on the current timestamp
filename=$(date +%Y%m%d)_ifconfig.log
output_file=$OUTPUT_DIR/$filename

# Calculate the number of seconds until the next five-minute interval
now=$(date +%s)
sleep_time=$(( INTERVAL - now % INTERVAL ))

# Start of transmit 
tx1=$(ifconfig $NETWORK_INTERFACE | awk '/TX packets/{print $5}')

# Wait until the next five-minute interval
#echo "Waiting $sleep_time seconds until the next interval..."
sleep $sleep_time

# End of transmit 
tx2=$(ifconfig $NETWORK_INTERFACE | awk '/TX packets/{print $5}')
tx_bytes=$(($tx2-$tx1))

# Output bytes transmiatted to a file
echo "$(date +%Y-%m-%d_%H:%M:%S) $tx_bytes" >> $output_file

# Find files older than the specified number of days and delete them
if find "$OUTPUT_DIR" -type f -mtime +"$DAYS_TO_KEEP" -delete -print; then
    echo "Deleted log files older than 30 days."
fi
# done

# # Remove the lock file at the end of script
# rm "$SCRIPT_LOCK"