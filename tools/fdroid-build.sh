# Should be run inside
# docker run --rm -itu vagrant --entrypoint /bin/bash   -v $(pwd):/build:z   -v $HOME/Documents/godot/fdroidserver:/home/vagrant/fdroidserver:Z   registry.gitlab.com/fdroid/fdroidserver:buildserver 

run() {
	echo -e "\033[34;1m== $*\033[0m"
	"$@"
}

df -h
. /etc/profile
export serverwebroot=$(pwd)/build
run echo $serverwebroot
export PATH="$fdroidserver:$PATH" PYTHONPATH="$fdroidserver"
export JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | awk -F'=' '{print $2}' | tr -d ' ')
run sdkmanager --install "platform-tools" "build-tools;34.0.0" "platforms;android-34" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;23.2.8568313"
run sudo apt-get update -y
run sudo apt-get install -y pkgconf clang scons imagemagick python3-pip python-is-python3 apksigner
cd /build
run fdroid readmeta
run fdroid rewritemeta net.canvoki.godot_dice_roller
run fdroid checkupdates --allow-dirty net.canvoki.godot_dice_roller
run fdroid lint net.canvoki.godot_dice_roller
run fdroid build -vl net.canvoki.godot_dice_roller

