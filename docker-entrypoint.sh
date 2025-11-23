#!/bin/bash
set -e

# Function to update properties file from env vars
update_properties() {
    local prefix=$1
    local file=$2
    
    # Create file if it doesn't exist (though it should exist now)
    if [ ! -f "$file" ]; then
        touch "$file"
    fi

    # Loop through environment variables starting with prefix
    env | grep "^$prefix" | while read -r line; do
        # Split into key and value
        key=$(echo "$line" | cut -d= -f1)
        value=$(echo "$line" | cut -d= -f2-)
        
        # Remove prefix
        prop_name=${key#$prefix}
        
        # Lowercase
        prop_name=$(echo "$prop_name" | tr '[:upper:]' '[:lower:]')
        
        # Replace _ with .
        prop_name=$(echo "$prop_name" | tr '_' '.')
        
        # Append to file (overriding previous values if loaded sequentially)
        echo "$prop_name=$value" >> "$file"
    done
}

# Update server.properties
update_properties "SERVER__" "config/server.properties"

# Update map.properties
update_properties "MAP__" "config/map.properties"

# Execute the command
exec "$@"
