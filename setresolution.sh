#!/bin/bash
#hack script to change resolution from a command line under Ubuntu Wayland by Douwe

monitor=\'$1\'
resolution=\'$2\'
scale=$3


if [ "$1" == "--help" ]
then
  echo -e `basename $0`" monitor resolution [scale]\n"
  echo "If the monitor parameter is not given a list of available resolutions (and their scales) per monitor will be listed"
  echo "If you do not specify the refresh rate for a resolution the first one in the list will be used"
  echo -e  "\nExample: "`basename $0`" HDMI-1 800x600@60.316539764404297 2.0"
  exit 0
fi

if [ -z "$1" ]
then
  gdbus call -e -d org.gnome.Mutter.DisplayConfig -o /org/gnome/Mutter/DisplayConfig -m org.gnome.Mutter.DisplayConfig.GetCurrentState\
  | awk -F'),' -v OFS='\n' '{$1=$1}1' | tr  "[()],'" ' '  | sed 's/ [ ]* / /g' | \
  perl -lne  'print /([ 0-9]*x[0-9]*\@[\.0-9]*) .*( 1.0 [ .0-9]*).*|uint32 [0-9]* ([A-Za-z0-9-]* ).*/'
  echo  -e "\nType "`basename $0`" --help for help"
 exit 0
fi

if [ -z "$scale" ]
then
  scale=1
fi

if [[ ! "$2" == *@* ]]
then
  resolution=\'`gdbus call -e -d org.gnome.Mutter.DisplayConfig -o /org/gnome/Mutter/DisplayConfig -m org.gnome.Mutter.DisplayConfig.GetCurrentState\
  | awk -F'),' -v OFS='\n' '{$1=$1}1' | tr  "[()],'" ' '  | sed 's/ [ ]* / /g' | \
  perl -lne  'print /([ 0-9]*x[0-9]*\@[\.0-9]*) .*( 1.0 [ .0-9]*).*|uint32 [0-9]* ([A-Za-z0-9-]* ).*/' | grep "$2" | awk '{print $1}' | head -1`\'
fi


serial=`gdbus call --session --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.GetResources | awk '{print $2}' | tr -d ','`
  
gdbus call --session --dest org.gnome.Mutter.DisplayConfig \
  --object-path /org/gnome/Mutter/DisplayConfig \
  --method org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig \
  $serial 1 "[(0, 0, $scale, 0, true, [($monitor, $resolution, [] )] )]" "[]" > /dev/null
  
  
    

