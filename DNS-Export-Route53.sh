#!/bin/bash

# Get the list of hosted zones
hostedZones=$(aws route53 list-hosted-zones --output json)

# Extract the IDs and names of the hosted zones
ids=$(echo "$hostedZones" | jq -r '.HostedZones[].Id')
names=$(echo "$hostedZones" | jq -r '.HostedZones[].Name')

# Convert names to lowercase and remove trailing dot
names_lower=$(echo "$names" | tr '[:upper:]' '[:lower:]' | sed 's/\.$//')

# Store the IDs and names in arrays
id_array=($ids)
name_array=($names_lower)

# Loop through each hosted zone
for ((i=0; i<${#id_array[@]}; ++i)); do
    # Extract hosted zone ID and name
    zoneId="${id_array[i]}"
    zoneName="${name_array[i]}"

    # Get the records of the hosted zone
    zoneRecords=$(aws route53 list-resource-record-sets --hosted-zone-id "$zoneId" --output json)

    # Remove trailing dot and replace '/' with '_' for filename compatibility
    filename=$(echo "$zoneName" | sed 's/\.$//' | tr '/' '_')

    # Export the records to a JSON file
    echo "$zoneRecords" > "${filename}-records.json"
done
