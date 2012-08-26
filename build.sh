#!/bin/bash

DEVICE=p1
for i in p1 p1c p1l p1n; do
  [ "$1" == "$i" ] && DEVICE="$i"
done

VARIANT=userdebug
for i in user userdebug eng; do
  [ "$2" == "$i" ] && VARIANT="$i"
done

ROM=""
for i in aokp cna pa; do
  [ "$3" == "$i" ] && ROM="$i"
done

USER="$4"

TARGET="$ROM_$DEVICE-$VARIANT"

if [ `uname` == "Darwin" ]; then
THREADS=4
else
THREADS=$(grep processor /proc/cpuinfo | wc -l)
fi

case "$1" in

  clean)
      make clean
      ( cd kernel/samsung/p1  ; make mrproper )
      ( cd kernel/samsung/p1c ; make mrproper )
      ;;
  $DEVICE|"")
      time {
        source build/envsetup.sh
	if [ $ROM = "pa" ]; then
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
	fi
        lunch "$TARGET"
        make -j$THREADS bacon
	if [ ! -z "$USER" ]; then
	scp out/target/product/$ROM_$DEVICE-*.zip $USER@upload.goo.im:/home/$USER/public_html/Roms/$ROM/
	fi
      }
      ;;
  *)
      echo
      echo "usage:" 
      echo "       ${0##*/} [ <action> ]"
      echo "       ${0##*/} [ <device> ] [ <build-variant> ]"
      echo
      echo "  <action> : clean|help"
      echo "  <device> : p1|p1c|p1l|p1n       		default=$DEVICE"
      echo "  <variant>: user|userdebug|eng   		default=$VARIANT"
      echo "  <rom>    : aokp|cna|pa"
      echo "  <user>   : only if your a goo.im dev! :P"
      ;;
esac
