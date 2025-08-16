#!/usr/bin/env bash

# Prompt the user for a hostname
hostname=$1

# Use dig to look up the IP address of the hostname
ip=$(dig +short "$hostname" | head -n 1)

# Use geoiplookup to get the location information
location=$(geoiplookup "$ip" | awk -F ": " '{print $2}')

# Display the IP address and location
echo "The IP address of $hostname is: $ip, location: $location"
