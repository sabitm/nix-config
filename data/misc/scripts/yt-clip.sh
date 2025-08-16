#!/usr/bin/env bash
#taken from https://unix.stackexchange.com/a/388148/48971

usage() {
  echo "Usage: $0 <command> <url> <from_time> <to_time> <output_name>"
  echo "Commands:"
  echo "  ytdlp   Fetch video URL using yt-dlp (default)"
  echo "  direct  Use the provided URL directly"
  echo "e.g.:"
  echo "$0 ytdlp https://www.youtube.com/watch?v=T1n5gXIPyws 00:00:25 00:00:42 intro.mp4"
  echo "$0 direct https://example.com/video.mp4 00:00:25 00:00:42 intro.mp4"
  exit 1
}

if [ $# -ne 5 ]; then
  usage
fi

command=$1
url=$2
from_time=$3
to_time=$4
output_name=$5

from_ts=$(date "+%s" -d "UTC 01/01/1970 $from_time")
to_ts=$(date "+%s" -d "UTC 01/01/1970 $to_time")
delta=$(($to_ts - $from_ts))
if [ $delta -lt 0 ]; then
  delta=0
fi
delta_time=$(date -u "+%T" -d @$delta)

case "$command" in
"ytdlp")
  result_url=$(yt-dlp -g --youtube-skip-dash-manifest "$url")

  readarray -t result_urls <<<"$result_url"
  video_url="${result_urls[0]}"
  audio_url="${result_urls[1]}"

  ffmpeg -ss "$from_time" -i "$video_url" -ss "$from_time" -i "$audio_url" \
    -to "$delta_time" -c copy -shortest "$output_name"
  ;;
"direct")
  ffmpeg -ss "$from_time" -i "$url" -to "$delta_time" -c copy "$output_name"
  ;;
*)
  usage
  ;;
esac
