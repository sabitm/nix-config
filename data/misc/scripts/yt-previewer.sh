#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <video_url> <interval_in_seconds>"
  echo "Example: $0 \"https://www.example.com/myvideo.mp4\" 5"
  exit 1
fi

VIDEO_URL="$1"
INTERVAL="$2"

# Ensure the interval is a positive number
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [ "$INTERVAL" -le 0 ]; then
  echo "Error: Interval must be a positive integer."
  exit 1
fi

TMP_DIR=$(mktemp -d)

# Custom headers (each separated by \r\n)
# Using $'...' ANSI-C quoting in bash to correctly interpret \r\n
HEADERS=$'Accept: */*\r\n\
Accept-Language: en-US,en;q=0.9\r\n\
Connection: keep-alive\r\n\
Referer: https://google.com/\r\n\
Sec-Fetch-Dest: video\r\n\
Sec-Fetch-Mode: no-cors\r\n\
Sec-Fetch-Site: cross-site\r\n\
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36\r\n\
sec-ch-ua: "Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"\r\n\
sec-ch-ua-mobile: ?0\r\n\
sec-ch-ua-platform: "Linux"\r\n'

# Execute the ffmpeg command
ffmpeg -headers "${HEADERS}" \
  -i "$VIDEO_URL" -vf "fps=1/$INTERVAL" "$TMP_DIR"/output_%04d.jpg

# Check the exit status of the ffmpeg command
if [ $? -eq 0 ]; then
  echo "Frames extracted successfully with an interval of $INTERVAL seconds."
else
  echo "Error: ffmpeg command failed."
  exit 1
fi

exit 0
