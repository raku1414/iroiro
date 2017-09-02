
#!/bin/bash
#need socat pidof mpv
mpvsocket="/tmp/mpvsocket"
tmpplaylist="/tmp/tl.m3u8"
if pidof mpv;then
  output=""
  for media in "$@"; do
    output+="${media}\n"
  done
  echo -e $output > $tmpplaylist
  echo "loadlist \"$tmpplaylist\" replace" | socat - $mpvsocket && rm $tmpplaylist
else 
  #mpv --player-operation-mode=pseudo-gui --idle=yes --input-ipc-server=$mpvsocket --ytdl-format='bestvideo[ext=mp4][width<=1920][height<=1080]+bestaudio[ext=m4a]' "$@"
  mpv --keep-open=yes --force-window=yes --input-ipc-server=$mpvsocket --ytdl-format='bestvideo[ext=mp4][width<=1920][height<=1080]+bestaudio[ext=m4a]' "$@"
fi
