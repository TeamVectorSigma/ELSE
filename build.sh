#!/bin/bash

ROM="$2"

DEVICE="$3"

VARIANT="$4"

USER="$5"

TARGET="$DEVICE-$VARIANT"

if [ -z "$SUBDIR" ] && [ -z "$ROMDIR" ]; then
	DIR=ROMs/$ROM/
fi
if [ ! -z "$SUBDIR" ] && [ ! -z "$ROMDIR" ]; then
	DIR=$SUBDIR/$ROMDIR/
fi
if [ -z "$SUBDIR" ] && [ ! -z "$ROMDIR" ]; then
	DIR=ROMs/$ROMDIR/
fi
if [ ! -z "$SUBDIR" ] && [ -z "$ROMDIR" ]; then
	DIR=$SUBDIR/$ROM/
fi

if [ `uname` == "Darwin" ]; then
	THREADS=4
	else
	THREADS=$(grep processor /proc/cpuinfo | wc -l)
fi

case "$1" in

  clean)
      read -p "who is your manufacturer and what is your device? e.g. samsung/p1 & asus/grouper: " KERNELDIR
      make clean
      ( cd kernel/$KERNELDIR  ; make mrproper )
      ( cd kernel/$KERNELDIR ; make mrproper )
      ;;
   rom)
        source build/envsetup.sh
	if [ -d vendor/cm/ ]; then
        	[ ! -d vendor/cm/proprietary ] && ( cd vendor/cm ; ./get-prebuilts )
	fi
        lunch "$ROM"_"$TARGET"
        make -j$THREADS bacon
	if [ ! -z "$USER" ]; then
		read -p "Is the directory public_html/$DIR ok for the ROM's destination? (y/n)" ANSWER
		if [ "$ANSWER" = "n" ]; then
			read -p "Do you want modify public_html/-->(ROMs)<--? (y/n)" ANSWER
			if [ "$ANSWER" = "y" ]; then
				read -p "Enter your prefered folder name within public_html/ folders: " SUBDIR
			fi
			read -p "Do you want the ROM to go somewhere else besides $ROM/ in the public_html/Roms/ folder? (y/n)" ANSWER
			if [ "$ANSWER" = "y" ]; then
				read -p "Enter your prefered folder name within public_html/Roms/ folders: " ROMDIR
			fi
		fi
		ssh $USER@upload.goo.im "
		if [ -z "$SUBDIR" ]; then
			if [ ! -d public_html/ROMs ]; then
				cd public_html/
				mkdir ROMs
				if [ -z "$ROMDIR" ]; then
				cd ROMs/
				mkdir $ROM
				else
				cd ROMs/
				mkdir $ROMDIR
				fi
			fi
			else
			if [ ! -d public_html/$SUBDIR ]; then
				cd public_html/
				mkdir $SUBDIR
				if [ -z "$ROMDIR" ]; then
				cd $SUBDIR/
				mkdir $ROM
				else
				cd $SUBDIR/
				mkdir $ROMDIR
				fi
			fi
		fi
		exit"
		scp out/target/product/$DEVICE/$ROM_$DEVICE-*.zip $USER@upload.goo.im:/home/$USER/public_html/$DIR
	fi
      ;;
 kernel)
	source build/envsetup.sh
	lunch "$ROM"_"$TARGET"
	make -j$THREADS out/target/product/$DEVICE/boot.img
      ;;
  help)
      echo
      echo "       ${0##*/} <action> <rom> <device> <varient> <user>"
      echo
      echo "  <action> : clean|help|kernel|rom"
      echo "  <rom>    : What Rom are you developing for? e.g. aokp|cm|cna|pa"
      echo "  <device> : Device's codename e.g. crespo|p1|tuna"
      echo "  <variant>: What build you prefer user|userdebug|eng"
      echo "	   user 	limited access; suited for production"
      echo "	   userdebug 	like user but with root access and debuggability; preferred for debugging and default in most rom's cases"
      echo "	   eng		development configuration with additional debugging tools"
      echo "  <user>   : only if your a goo.im dev! enter it here :P and this will upload it for you :)"
      ;;
     *)
      echo
      echo "usage:" 
      echo "       ${0##*/} <action> <rom> <device> <varient> <user>"
      echo
      echo "  <action> : clean|help|kernel|rom"
      echo "  <rom>    : e.g. aokp|cm|cna|pa"
      echo "  <device> : e.g. crespo|p1|tuna"
      echo "  <variant>: e.g. user|userdebug|eng"
      echo "  <user>   : only if your a goo.im dev! :P"
      ;;
esac
