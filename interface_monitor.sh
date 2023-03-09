## CRON job (crontab -e):
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# */5 * * * * /root/interface_monitor.sh
####################################################
#!/bin/bash
OUTPUT_DIR="/root/bandwidth_interface"
DAYS_TO_KEEP=30
INTERVAL=300 # 5 minutes
DNSNAME=$(awk 'NR==3' /etc/init.d/icdnddns.sh | cut -d "=" -f2 | cut -d "'" -f2)
SERVER_URL="http://210.23.11.106:3000/bandwidth_interface" 

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

# Calculate the number of seconds until the next five-minute interval
sleep_time=$(( INTERVAL - $(date -u +%s) % INTERVAL ))

# Start of transmit 
tx1=$(ifconfig $NETWORK_INTERFACE | awk '/TX packets/{print $5}')

# Wait until the next five-minute interval
#echo "$(date -u +%Y-%m-%d %H:%M:%S) - Waiting $sleep_time seconds until the next interval..."
if [ $sleep_time -gt 0 ]; then
    sleep $sleep_time
fi

# End of transmit 
tx2=$(ifconfig $NETWORK_INTERFACE | awk '/TX packets/{print $5}')
tx_bytes=$(($tx2-$tx1))

OUTPUT_DIR=$OUTPUT_DIR/$(date -u +%Y-%m)
if [ ! -d $OUTPUT_DIR ]; then
    mkdir -p -m 755 $OUTPUT_DIR
fi

# Generate a unique filename based on the current timestamp
filename=$(date -u +%Y%m%d)_tx.log
output_file=$OUTPUT_DIR/$filename

# Output bytes transmiatted to a file
echo "$(date -u +%Y-%m-%d_%H:%M:%S) $tx_bytes" >> $output_file

# Send data to the server
curl -v -X POST $SERVER_URL \
  -H 'Content-Type: application/json' \
  -d "{\"timestamp\": $(date -u +%s), \"devicename\": \"$(hostname)\", \"ddns\": \"$DNSNAME\", \"txbytes\": $tx_bytes}"

# Find files older than the specified number of days and delete them
if find "$OUTPUT_DIR" -type f -mtime +"$DAYS_TO_KEEP" -delete -print; then
    echo "$(date -u +%Y-%m-%d_%H:%M:%S) - Deleted log files older than 30 days."
fi
# done

# # Remove the lock file at the end of script
# rm "$SCRIPT_LOCK"