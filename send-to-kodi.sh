#!/usr/bin/env bash

# requires curl and xclip or wl-paste

# first check if there an argument if so attempt to play that
# if not, check the copy buffers

# Kodi settings
# HOST examples
# http://127.0.0.1:8080
# https://kodi.example.com
HOST="http://127.0.0.1:8080"

# AUTH is `echo -ne "user:password" |base64 --wrap 0`
# reminder base64 is not encryption
AUTH="dXNlcjpwYXNzd29yZA=="

if [[ -n "$1" ]] ; then
	BUFFER=$1
else

if [[ $XDG_SESSION_TYPE == wayland ]] ; then
	PASTE_PRIMARY="wl-paste --primary"
	PASTE_CLIPBOARD="wl-paste"
fi

if [[ $XDG_SESSION_TYPE == x11 ]] ; then
	PASTE_PRIMARY="xclip -out -selection primary"
	PASTE_CLIPBOARD="xclip -out -selection clipboard"
fi

# crude check to see which copy buffer has a URL, as some application do not copy to XA_PRIMARY.
BUFFER=$($PASTE_PRIMARY)
if ! [[ $BUFFER =~ ^http ]] ; then
	BUFFER=$($PASTE_CLIPBOARD)
fi
fi

# get real URL from twitter links
if [[ $BUFFER =~ ^https:\/\/t\.co ]] ; then
	BUFFER=$(curl -o /dev/null --silent --head --write-out '%{redirect_url}' "$BUFFER" )
fi

# https://github.com/dirkjanm/firefox-send-to-xbmc/blob/master/webextension/main.js
if [[ $BUFFER =~  ^.*twitch.tv\/([a-zA-Z0-9_]+)$ ]] ; then
	NAME=${BASH_REMATCH[1]}
	JSON='{"jsonrpc":"2.0","method":"Player.Open","params":{"item":{"file":"plugin://plugin.video.twitch/?mode=play&channel_name='$NAME'"}},"id":"2"}'

elif [[ $BUFFER =~ ^.*twitch.tv\/videos\/([0-9]+)$ ]] ; then
	NAME=${BASH_REMATCH[1]}
	JSON='{"jsonrpc":"2.0","method":"Player.Open","params":{"item":{"file":"plugin://plugin.video.twitch/?mode=play&video_id='$NAME'"}},"id":"2"}'

elif [[ $BUFFER =~ ^.*vimeo.com\/([0-9]+) ]] ; then
	NAME=${BASH_REMATCH[1]}
	JSON='{"jsonrpc":"2.0","method":"Player.Open","params":{"item":{"file":"plugin://plugin.video.vimeo/play/?video_id='$NAME'"}},"id":"2"}'

elif [[ $BUFFER =~ ^.*youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=([^#\&\?]*).*  ]] ; then
	NAME=${BASH_REMATCH[1]}
	JSON='{"jsonrpc":"2.0","method":"Player.Open","params":{"item":{"file":"plugin://plugin.video.youtube/play/?video_id='$NAME'"}},"id":"2"}'
fi

if [[ $JSON ]] ; then
	curl \
	--request POST $HOST/jsonrpc \
	--header "Authorization: Basic $AUTH" \
	--header "Content-Type: application/json" \
	--data "$JSON" \
	--silent > /dev/null
fi
