#!/bin/sh

### BEGIN INIT INFO
# PROVIDES:         lumos
# Required-Start:   $remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:    2 3 4 5
# Default-Stop:     0 1 6
# Short-Description: Lumos
# Description:      Lumos
### END INIT INFO

STREAM_KEY=$(cat ~/.twitch_key)
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



DAEMON=`which ffmpeg`
DAEMON_ARGS="-f v4l2 -framerate 25 -video_size 640x480 -i /dev/video1 -f alsa -i pulse -f flv -an -ar $AUDIO_RATE "
DAEMON_ARGS="$DAEMON_ARGS -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p "
DAEMON_ARGS="$DAEMON_ARGS -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal "
DAEMON_ARGS="$DAEMON_ARGS -bufsize $CBR rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"


DAEMON_NAME=sirannecam       # The name of this file
# PIDFILE=/var/run/$DAEMON_NAME.pid
# DAEMON_USER=root
PIDFILE=~/tmp/pid/$DAEMON_NAME.pid
DAEMON_USER=csrobot

try () {
    $DAEMON $DAEMON_ARGS
}

. /lib/lsb/init-functions

do_start () {
    log_daemon_msg "Starting SirAnneCam"
    start-stop-daemon --start --background --quiet --pidfile $PIDFILE --make-pidfile --user $DAEMON_USER --chuid $DAEMON_USER --exec $DAEMON -- $DAEMON_ARGS
    log_end_msg $?
}

do_stop () {
    log_daemon_msg "Stopping SirAnneCam"
    start-stop-daemon --stop --pidfile $PIDFILE --retry 10
    log_end_msg $?
}

case "$1" in
    start|stop)
        do_${1}
        ;;

    restart|reload|force-reload)
        do_stop
        do_start
        ;;
    status)
        status_of_proc "$DAEMON_NAME" "$DAEMON" && exit 0 || exit $?
        ;;
    *)
        echo "Usage: /etc/init.d/$DAEMON_NAME {start|stop|restart|status}"
        exit 1
        ;;
esac
exit 0
