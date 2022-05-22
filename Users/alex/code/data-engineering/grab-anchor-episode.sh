#!/usr/bin/env bash

# Download a podcast episode from anchor.fm
#
# Usage:
# grab-anchor-episode "https://anchor.fm/emerge/episodes/Robert-MacNaughton---Learnings-from-the-Life-and-Death-of-the-Integral-Center-e31val" # (m4a example)
# grab-anchor-episode "https://anchor.fm/free-chapel/episodes/Are-You-Still-In-Love-With-Praise--Pastor-Jentezen-Franklin-e19u4i8"             # (mp3 example)
#
# anchor.fm serves a list of m4a or mp3 files that need to be concatenated with ffmpeg.
#
# For debugging, uncomment:
set -o verbose

set -eu -o pipefail

url=$1
json=$(curl -sL "$url" | ggrep -P -o 'window.__STATE__ = .*' | cut -d ' ' -f 3- | sed -r 's/;$//g')
ymd=$(echo -E $json | jq -r '.episodePreview.publishOn' | cut -d 'T' -f 1)

extension=$((echo -E $json | jq -r '.[].episodeEnclosureUrl' | ggrep -F --max-count=1 :// | ggrep -oP '\.[0-9a-z]+$' | cut -d . -f 2) || echo m4a)
output_basename=$ymd-$(basename -- "$url").$extension
if [[ -f "$output_basename" ]]; then
	echo "$output_basename already exists; skipping download"
	exit
fi
temp_dir="$(mktemp -d)"
cd "$temp_dir"
audio_urls=$(echo -E $json | jq -r '.station.audios|map(.audioUrl)|.[]')
for i in $audio_urls; do
	output_file=$(basename -- "$i")
	wget "$i" -O "$output_file"
	echo "file '$output_file'" >> .copy_list
done
ffmpeg -f concat -safe 0 -i .copy_list -c copy "$output_basename"
cd -
mv "$temp_dir/$output_basename" ./
rm -rf "$temp_dir"
