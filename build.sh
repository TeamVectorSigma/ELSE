#!/bin/bash

DEVICE="$1"

VARIANT=userdebug
for i in user userdebug eng; do
  [ "$2" == "$i" ] && VARIANT="$i"
done

ROM="$3"

USER="$4"

TARGET="$DEVICE-$VARIANT"

if [ `uname` == "Darwin" ]; then
THREADS=4
else
THREADS=$(grep processor /proc/cpuinfo | wc -l)
fi

if [ -z "$ROM" ]; then
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
exit 1
fi

case "$1" in

  clean)
      make clean
      ( cd kernel/samsung/p1  ; make mrproper )
      ( cd kernel/samsung/p1c ; make mrproper )
      ;;
  $DEVICE|"")
        source build/envsetup.sh
	if [ $ROM = "pa" ]; then
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
	fi
        lunch "$ROM"_"$TARGET"
        make -j$THREADS bacon
	if [ ! -z "$USER" ]; then
	scp out/target/product/$ROM_$DEVICE-*.zip $USER@upload.goo.im:/home/$USER/public_html/Roms/$ROM/
	fi
      ;;
  help)
      echo
      echo  
      echo
      echo "  <action> : clean|help"
      echo "  <device> : Device's codename e.g. crespo|p1|tuna"
      echo "  <variant>: What build you prefer user|userdebug|eng   	default=$VARIANT"
      echo "      # user 	limited access; suited for production
		  # userdebug 	like user but with root access and debuggability; preferred for debugging and default in most rom's cases
		  # eng		development configuration with additional debugging tools"	
      echo "  <rom>    : What Rom are you developing for? e.g. aokp||cm|cna|pa"
      echo "  <user>   : only if your a goo.im dev! enter it here :P"
      ;;
esac
