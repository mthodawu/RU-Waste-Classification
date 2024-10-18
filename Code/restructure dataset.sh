#!/bin/bash

# Source directory
SRC_DIR="Trashnet-resized"

# List of materials to exclude from 'other' directory
MATERIALS=("plastic" "metal" "cardboard" "paper" "trash" "glass")

# Base directory (the folder where '_and_other' directories will be created)
BASE_DIR="."

# Loop through each material
for MATERIAL in "${MATERIALS[@]}"; do
    # Create new directory with the format '{material}_and_other'
    DEST_DIR="${BASE_DIR}/${MATERIAL}_and_other"

    mkdir -p "$DEST_DIR"
    cp -r "$SRC_DIR/$MATERIAL" "$DEST_DIR/"

    # Create 'other' directory inside the new destination directory
    mkdir -p "$DEST_DIR/other"

    # Loop through all subdirectories in the source directory
    for SUBFOLDER in "$SRC_DIR"/*; do
        # Get the name of the subfolder
        FOLDER_NAME=$(basename "$SUBFOLDER")

        # Copy subfolder to 'other' directory, excluding the material
        if [[ "$FOLDER_NAME" != "$MATERIAL" ]]; then
            cp -r "$SUBFOLDER" "$DEST_DIR/other/"
        fi
    done

    if [ -d "$DEST_DIR/other" ]; then
        echo "Processing '$DEST_DIR/other'..."

        id=1 # counter

        # Loop through all subfolders in 'other'
        for SUBFOLDER in "$DEST_DIR/other"/*; do
            if [ -d "$SUBFOLDER" ]; then
                echo "Moving contents of '$SUBFOLDER' to '$DEST_DIR/other/'..."

                # Move the contents of the subfolder to the 'other' directory
                mv "$SUBFOLDER"/* "$DEST_DIR/other/"

                # Remove the now empty subfolder
                rmdir "$SUBFOLDER"
            fi
        done

        # Loop through all files in 'other' and rename them
        for FILE in "$DEST_DIR/other"/*; do
            if [ -f "$FILE" ]; then
               
                EXT="${FILE##*.}"

                # Rename the file to 'other{id}.{extension}'
                NEW_NAME="$DEST_DIR/other/other${id}.$EXT"
                mv "$FILE" "$NEW_NAME"
                echo "Renamed '$FILE' to '$NEW_NAME'"

                # Increment the counter
                id=$((id + 1))
            fi
        done

        echo "Completed processing '$DEST_DIR/other'."
    else
        echo "'other' directory not found in '$DEST_DIR'. Skipping..."
    fi

done

echo "Dataset restructured and files renamed."

