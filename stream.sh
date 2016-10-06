#!/bin/sh
# stream key. You can set this manually.
STREAM_KEY=$(cat ~/.twitch_key)

# stream url. Note the formats for twitch.tv and justin.tv
# twitch:"rtmp://live.twitch.tv/app/$STREAM_KEY"
# justin:"rtmp://live.justin.tv/app/$STREAM_KEY"
STREAM_URL="rtmp://live.twitch.tv/app/$STREAM_KEY"

# ffmpeg \
# -f v4l2 -framerate 25 -video_size 640x480 -i /dev/video1 -an \
# -vcodec libx264 -pix_fmt yuv420p -s "640x480" \
# -acodec libmp3lame -threads 6 -qscale 5 -b 64KB \
# -f flv -ar 22050 "$STREAM_URL"
# 
# ffmpeg \
# -f alsa -ac 2 -i "pulse" \
# -f x11grab -s $(xwininfo -root | awk '/geometry/ {print $2}'i) -r "30" -i :0.0 \
# -vcodec libx264 -pix_fmt yuv420p -s "640x360" -vpre "fast" \
# -f flv -ar 22050 "$STREAM_URL"

#https://wiki.archlinux.org/index.php/Streaming_using_twitch.tv
INRES="1920x1080" # input resolution
OUTRES="1920x1080" # output resolution
FPS="15" # target FPS
GOP="30" # i-frame interval, should be double of FPS, 
GOPMIN="15" # min i-frame interval, should be equal to fps, 
THREADS="2" # max 6
CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
QUALITY="ultrafast"  # one of the many FFMPEG preset
AUDIO_RATE="44100"
SERVER="live" # twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list

# ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE \
ffmpeg -f v4l2 -framerate 25 -video_size 640x480 -i /dev/video1 -f alsa -i pulse -f flv -an -ar $AUDIO_RATE \
-vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p \
-s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal \
-bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"


#WORKING, WITH AUDIO
# ffmpeg -f v4l2 -framerate 25 -video_size 640x480 -i /dev/video1 -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE \
# -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p \
# -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal \
# -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
