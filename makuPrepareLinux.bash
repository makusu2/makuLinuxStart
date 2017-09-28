#!/usr/bin/env bash
#Steven
#Maku
#If permission denied, do chmod +x makuPrepareLinux.bash
#Todo: Make output quieter
#Requirements: Git installed
log ()
{
	log=/var/log/makuPrepareLinuxLog.log
	sudo touch $log
	date=`date '+%Y-%m-%d %H:%M:%S'`
	logMessage="$1"
	sudo echo "$date $logMessage" >> log
}

if [ $EUID != 0 ]; then
	#if not root
	log "User is not root, attempting to run as root..."
	sudo "$0" "$@"
	#Run current script as root
	exit $?
	#Then exit this one (With the root one running)
fi
log "User is root"
log "Checking for updates..."
sudo apt-get upgrade -y
log "Attempting updates..."
sudo apt-get update -y

log "Installing Git..."
sudo apt install -y git
git config --global user.name "Maku"
git config --global user.email "makusu2@gmail.com"
log "Installed Git!"

log "Installing Vim..."
sudo apt install -y vim
#sudo update-alternatives --config editor
	#Dunno why this is a thing
log "Installed Vim!"

log "Installing the ultimate VimRC..."
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
log "Installed the ultimate VimRC!"

log "Installing Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update && sudo apt install sublime-text
log "Installed Sublime Text!"

log "Setting Sublime Text as default editor..."
sed -i 's/gedit/sublime_text/g' /usr/share/applications/defaults.list
	#Replacing all instances of "gedit" with "sublime_text" in the defaults file
log "Set Sublime Text as default editor!"

log "Installing VLC..."
sudo apt install -y vlc
log "Installed VLC!"

log "Installing Chromium..."
sudo apt install -y chromium-browser
log "Installed Chromium!"

log "Installing inxi..."
sudo add-apt-repository ppa:unit193/inxi
sudo apt update
sudo apt-get install inxi
log "Installed inxi"

log "Disabling terminal case sensitivity..."
# If ~./inputrc doesn't exist yet, first include the original /etc/inputrc so we don't override it
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
# Add option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc
	#Source: https://askubuntu.com/questions/87061/can-i-make-tab-auto-completion-case-insensitive-in-the-terminal
log "Disabled terminal case sensitivity!"

log "Installing compizConfig..."
sudo apt install -y compizconfig-settings-manager
sudo apt install -y compiz-plugins
log "Installed compizConfig! You still need to import your profile."

log "Importing compizConfig settings..."
python /tmp/makuLinuxStartTemp/importCompiz.py
log "Imported compizConfig settings!"

log "Cleaninig up launcher..."
sudo gsettings set com.canonical.Unity.Launcher favorites "['application://ubiquity.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
log "Cleaned up launcher"

log "Adding aliases..."
sudo echo 'alias snip="gnome-screenshot -ac"' >> ~/.bash_aliases
log "Added aliases"

log "Adding numlockx and enabling numlock on boot..."
sudo apt install -y numlockx
sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local
log "Added numlockx and enabled numlock on boot!"

log "Ending here, but I plan on adding more stuff"