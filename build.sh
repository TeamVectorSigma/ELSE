#!/bin/bash

DEVICE="$2"

VARIANT="$3"

ROM="$4"

USER="$5"

TARGET="$DEVICE-$VARIANT"

PATH=ROMs/$ROM/

if [ `uname` == "Darwin" ]; then
THREADS=4
else
THREADS=$(grep processor /proc/cpuinfo | wc -l)
fi

case "$1" in

  clean)
      make clean
      ( cd kernel/samsung/$DEVICE  ; make mrproper )
      ( cd kernel/samsung/$DEVICE ; make mrproper )
      ;;
   rom)
        source build/envsetup.sh
	if [ -d vendor/cm/ ]; then
        [ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
	fi
        lunch "$ROM"_"$TARGET"
        make -j$THREADS bacon
	if [ ! -z "$USER" ]; then
	read -p "do you want the file to go somewhere else besides /Roms/$ROM/ in the public_html folder? (y/n)" ANSWER
	if [ "$ANSWER" = "y" ]; then
	read PATH
	fi
	ssh $USER@upload.goo.im "
	if [ ! -d public_html/$PATH ]; then
	cd public_html/
	mkdir $PATH
	fi"
	scp out/target/product/$DEVICE/$ROM_$DEVICE-*.zip $USER@upload.goo.im:/home/$USER/public_html/$PATH
	fi
      ;;
 kernel)
	source build/envsetup.sh
	lunch "$ROM"_"$TARGET"
	make -j$THREADS out/target/product/$DEVICE/boot.img
      ;;
  help)
      echo
      echo  
      echo
      echo "  <action> : clean|help|kernel|rom"
      echo "  <device> : Device's codename e.g. crespo|p1|tuna"
      echo "  <variant>: What build you prefer user|userdebug|eng"
      echo "	   user 	limited access; suited for production"
      echo "	   userdebug 	like user but with root access and debuggability; preferred for debugging and default in most rom's cases"
      echo "	   eng		development configuration with additional debugging tools"
      echo "  <rom>    : What Rom are you developing for? e.g. aokp||cm|cna|pa"
      echo "  <user>   : only if your a goo.im dev! enter it here :P and this will upload it for you :)"
      ;;
     *)
      echo
      echo "usage:" 
      echo "       ${0##*/} [ <action> ]"
      echo "       ${0##*/} [ <device> ] [ <build-variant> ]"
      echo
      echo "  <action> : clean|help|kernel|rom"
      echo "  <device> : e.g. crespo|p1|tuna"
      echo "  <variant>: e.g. user|userdebug|eng"
      echo "  <rom>    : e.g. aokp|cm|cna|pa"
      echo "  <user>   : only if your a goo.im dev! :P"
      ;;
esac
