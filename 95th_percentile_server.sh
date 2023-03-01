# 0 0 1 * * /path/to/calculate_percentile.sh

#!/bin/bash
OUTPUT_DIR="/root/icdn-bandwidth_interface"
cd $OUTPUT_DIR
PERCENTILE=95

# Loop through all folders (exclude non folder)
for FOLDER_PATH in $( find $OUTPUT_DIR -mindepth 1 -maxdepth 1 -type d); do
    echo ""
    echo "Reading Folder: " $FOLDER_PATH

    # Get the previous month
    PREV_MONTH=$(date -d "-1 month" +%Y-%m)

    # Get all the tx.log files in the folder
    TX_FILES=$(find "$FOLDER_PATH/$PREV_MONTH" -name "*_tx.log")

    # Initialize an array to hold the bandwidth values
    TX_VALUES=()

    # Loop through the tx.log files and extract the bandwidth values
    for FILE in ${TX_FILES[@]}; do
        echo ""
        echo "Getting bandwdith from:" $FILE
        # Read the file and extract the bandwidth values from each line
        TX_VALUES+=($(awk '{print $4}' "$FILE"))
    done
    echo ""
    echo "TX_VALUES (${#TX_VALUES[@]}):" ${TX_VALUES[@]}

    # Calculate the 95th percentile
    SORTED_VALUES=($(printf '%s\n' "${TX_VALUES[@]}" | sort -n))
    echo ""
    echo "SORTED_VALUES (${#SORTED_VALUES[@]}):" ${SORTED_VALUES[@]}

    PERCENTILE_INDEX=$(((${#TX_VALUES[@]}*95+${PERCENTILE})/100-1))
    echo ""
    echo "PERCENTILE_INDEX:" $PERCENTILE_INDEX

    PERCENTILE_VALUE=${SORTED_VALUES[$PERCENTILE_INDEX]}

    # Output the result
    echo ""
    echo "95th percentile: $PERCENTILE_VALUE"
    echo ""
    echo "${PERCENTILE_VALUE}" > "$FOLDER_PATH/${PREV_MONTH}/${PREV_MONTH}_95th_percentile.txt"
    echo ""
    echo "File output to: $FOLDER_PATH/${PREV_MONTH}/${PREV_MONTH}_95th_percentile.txt"
done 