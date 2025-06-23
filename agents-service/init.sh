#!/bin/bash

# This script securely stores your Google Cloud Project ID in a local file
# for other scripts in the Menopause RAG Agent project to use.

PROJECT_FILE="$HOME/project_id.txt"

echo "--- Setting Google Cloud Project ID File ---"

# Prompt the user for their Google Cloud Project ID
read -p "Please enter your Google Cloud project ID: " user_project_id

# Check if the user entered a value
if [[ -z "$user_project_id" ]]; then
  echo "Error: No project ID was entered. Exiting."
  exit 1 # Exit the script with an error code
fi

echo "You entered: $user_project_id"

# Write the project ID to the specified file.
# Using > will overwrite the file if it already exists, ensuring it's up-to-date.
echo "$user_project_id" > "$PROJECT_FILE"

# Check if the write operation was successful
if [[ $? -eq 0 ]]; then
  echo "Successfully saved project ID to $PROJECT_FILE"
else
  echo "Error: Failed to save your project ID: $user_project_id."
  exit 1
fi

echo "--- Initial setup complete ---"
exit 0