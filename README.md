ELSE
====

Easy Little Script for Everything

Basically a script to automate my builds and uploads for me @ goo.im

This script can be added to any build evironment by adding the folowing line to the manifest (you also need to add a remote if github is not default)

	<project path="ELSE/" name="henryedwardrose/ELSE" remote="NAMEOFREMOTE" revision="master">
  	  <copyfile src="build.sh" dest="build.sh" />
  	</project>
	
The script can be executed by running the folowing commands

You must run this after your first sync:

	chmod 0755 build.sh

Now you can run the script itself:
	
	./build.sh <action> <rom> <device> <varient> <user>

	<action> : clean|help|kernel|rom
	<rom>    : What Rom are you developing for? e.g. aokp||cm|cna|pa
	<device> : Device's codename e.g. crespo|p1|tuna
	<variant>: What build you prefer user|userdebug|eng
		user 	limited access; suited for production
		userdebug 	like user but with root access and debuggability; preferred for debugging and default in most rom's cases
		eng		development configuration with additional debugging tools
	** <user>   : only if your a goo.im dev! enter it here :P and this will upload it for you :)

** This is optional! only if you are a goo.im dev!

any questions? always welcome contact me:
	henryedwardrose @ XDA Developers & henryedwardrose@gmail.com