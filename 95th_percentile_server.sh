# 0 0 1 * * /path/to/calculate_percentile.sh

#!/bin/bash
OUTPUT_DIR = "/root/icdn-bandwidth_interface";

# Loop through all folders (exclude non folder)
for FOLDER_PATH in $(find $OUTPUT_DIR -type d  -prune); do

    # Get the previous month
    PREV_MONTH=$(date -d "-1 month" +%Y-%m)

    # Get the folder path
    FOLDER_PATH="$FOLDER_PATH/$PREV_MONTH"

    # Get all the tx.log files in the folder
    TX_FILES=($(find "$FOLDER_PATH" -name "*_tx.log"))

    # Initialize an array to hold the bandwidth values
    TX_VALUES=()

    # Loop through the tx.log files and extract the bandwidth values
    for FILE in "${TX_FILES[@]}"; do
        # Read the file and extract the bandwidth values from each line
        TX_VALUES+=($(awk '{print $4}' "$FILE"))
    done

    # Calculate the 95th percentile
    NUM_VALUES=${#TX_VALUES[@]}
    SORTED_VALUES=($(echo "${TX_VALUES[@]}" | tr ' ' '\n' | sort -n))
    # Round up
    95_PERCENTILE_INDEX=$(echo "0.95 * $NUM_VALUES" | bc | awk '{print int($1+0.5)}')
    95_PERCENTILE_VALUE=${SORTED_VALUES[$95_PERCENTILE_INDEX]}

    # Output the result
    echo "95th percentile of ${FOLDER_PATH} is $95_PERCENTILE_VALUE"
    echo "${95_PERCENTILE_VALUE}" > "$FOLDER_PATH/${PREV_MONTH}_95th_percentile.txt"
done