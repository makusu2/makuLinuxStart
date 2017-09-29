#!/usr/bin/env bash
#Steven
#Maku
#If permission denied, do chmod +x makuPrepareLinux.bash
#Todo: Make output quieter
#Requirements: Git installed
log ()
{
	log=/var/tmp/log/makuPrepareLinuxLog.log
	#sudo touch $log
	date=`date '+%Y-%m-%d %H:%M:%S'`
	logMessage="$1"
	echo "$date $logMessage" >> $log
	echo " $logMessage"
}

makuInstall()
{
	longLog=/var/tmp/log/makuPrepareLinuxLongLog.log
	programName="$1"
	date=`date '+%Y-%m-%d %H:%M:%S'`
	echo "     Installing $1 at $date:" >> $longLog
	sudo apt-get install -y "$programName" >> $longLog
}

 if [ $EUID == 0 ]; then
	echo "YOU CANNOT RUN AS ROOT"
	# #if not root
	# log "User is not root, attempting to run as root..."
	# sudo "$0" "$@"
	# #Run current script as root
	# exit $?
	# #Then exit this one (With the root one running)
fi

set -e
	#Making code exit on error
	
mkdir -p /var/tmp/log
log=/var/tmp/log/makuPrepareLinuxLog.log
longLog=/var/tmp/log/makuPrepareLinuxLongLog.log
touch $log
touch $longLog

log "Making apt-get wait for lock..."
sudo mv /tmp/makuLinuxStartTemp/apt-get.bash /usr/local/sbin/apt-get
sudo chmod +x /usr/local/sbin/apt-get
log "Made apt-get wait for lock"


log "Checking for updates..."
sudo apt-get update -y >> $longLog
log "Attempting updates..."
sudo apt-get upgrade -y >> $longLog

log "Setting Git properties..."
git config --global user.name "Maku" >> $longLog
git config --global user.email "makusu2@gmail.com" >> $longLog
log "Git properties set!"

log "Installing Vim..."
makuInstall vim
#sudo update-alternatives --config editor
	#Dunno why this is a thing
log "Installed Vim!"

log "Installing the ultimate VimRC..."
git clone -q --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime >> $longLog
sh ~/.vim_runtime/install_awesome_vimrc.sh >> $longLog
log "Installed the ultimate VimRC!"

log "Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list >> $longLog
sudo apt-get update >> $longLog
makuInstall sublime-text
log "Installed Sublime Text!"

log "Setting Sublime Text as default editor..."
sudo sed -i 's/gedit/sublime_text/g' /usr/share/applications/defaults.list >> $longLog
	#Replacing all instances of "gedit" with "sublime_text" in the defaults file
log "Set Sublime Text as default editor!"

log "Installing VLC..."
makuInstall vlc
log "Installed VLC!"

log "Installing Chromium..."
makuInstall chromium-browser
log "Installed Chromium!"

log "Installing inxi..."
sudo add-apt-repository -y ppa:unit193/inxi > /dev/null 2>&1
	#The 2>&1 thing means "if it's an error, DO print to terminal"
sudo apt-get update >> $longLog
makuInstall inxi
log "Installed inxi"

log "Disabling terminal case sensitivity..."
# If ~./inputrc doesn't exist yet, first include the original /etc/inputrc so we don't override it
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc
	#Source: https://askubuntu.com/questions/87061/can-i-make-tab-auto-completion-case-insensitive-in-the-terminal
log "Disabled terminal case sensitivity!"

log "Installing compizConfig..."
makuInstall compizconfig-settings-manager
makuInstall compiz-plugins
log "Installed compizConfig! You still need to import your profile."


log "Cleaning up launcher..."
gsettings set com.canonical.Unity.Launcher favorites "['application://ubiquity.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']" >> $longLog
log "Cleaned up launcher! (Reboot may be necessary)"

log "Adding aliases..."
sudo echo 'alias snip="gnome-screenshot -ac"' >> ~/.bash_aliases
log "Added aliases"

log "Adding numlockx and enabling numlock on boot..."
makuInstall numlockx
sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local >> $longLog
log "Added numlockx and enabled numlock on boot!"

# log "Importing compizConfig settings..."
# python /tmp/makuLinuxStartTemp/importCompiz.py '/tmp/makuLinuxStartTemp/compizSettings.profile'
	# #So, it worked when I used this code alone, but it's not working in the script...
# log "Imported compizConfig settings!"

log "Performing updates and upgrades again..."
sudo apt-get update -y >> $longLog
sudo apt-get upgrade -y >> $longLog
log "Performed updates and upgrades again"

log "Ending here, but I plan on adding more stuff"