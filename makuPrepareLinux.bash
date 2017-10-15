#!/usr/bin/env bash
#Steven
#Maku

#Todo:
#	edit boot settings (like grub timeout)
#	Switches:
#		server: Install openssh-server
#		verbose: Redirect to log but also to terminal
#		silent: Dont print to terminal at all
#Disable autocomplete on atom
#	Actually don't; just make enter not activate it
#Make chromium automatically ask for user/pass and load addons and extensions

makuInstall()
{
	#Okay, so testing if I echo here and redirect back in the main body
	#longLog=/var/tmp/log/makuPrepareLinuxLongLog.log
	programName="$1"
	date=`date '+%Y-%m-%d %H:%M:%S'`
	echo "     Installing $1 at $date: $date"
	sudo apt-get install -y "$programName"
}
preInstallations()
{
	echo "Making apt-get wait for lock..."
	sudo mv /tmp/makuLinuxStartTemp/apt-get.bash /usr/local/sbin/apt-get
	sudo chmod +x /usr/local/sbin/apt-get
	echo "Made apt-get wait for lock"
	updateUpgrade

}
performInstallations()
{

	echo "     Now starting installations..."

	echo "Testing for vmware..."
	if (grep -q ^flags.*\ hypervisor /proc/cpuinfo) then
		echo "Device is a VM, installing VMWareTools..."
		makuInstall open-vm-tools
		echo "VMWareTools installed!"
	else
		echo "Device is not a VM"
	fi

	echo "Installing the ultimate VimRC..."
	git clone -q --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
	sh ~/.vim_runtime/install_awesome_vimrc.sh
	echo "Installed the ultimate VimRC!"

	echo "Installing Sublime Text..."
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	updateUpgrade
	makuInstall sublime-text
	echo "Installed Sublime Text!"

	sudo add-apt-repository -y ppa:webupd8team/atom
	updateUpgrade
	makuInstall atom

	echo "Installing Steam..."
	sudo add-apt-repository -y multiverse > /dev/null 2>&1
	updateUpgrade
	makuInstall steam
	echo "Installed Steam!"


	sudo add-apt-repository -y ppa:unit193/inxi
	updateUpgrade
	makuInstall inxi

	#makuInstall compizconfig-settings-manager
	#makuInstall compiz-plugins
	#makuInstall ccsm
	makuInstall gfortran
	makuInstall gimp
	makuInstall audacity
	makuInstall chromium-browser
	makuInstall vlc
	makuInstall vim
	makuInstall texlive-latex-base
	makuInstall grace
	makuInstall pip3
	makuInstall hardinfo

	echo "     Installations complete!"

}
postInstallations()
{
	echo "Setting Git properties..."
	git config --global user.name "Maku"
	git config --global user.email "makusu2@gmail.com"
	git config credential.helper store
	echo "Git properties set!"

	echo "Installing important pip3 modules..."
	sudo -H pip3 install compizconfig
	sudo -H pip3 install discord
	echo "Installed important pip3 modules"

	echo "Importing atom settings..."
  mkdir -p ~/.atom/
	sudo -H cp -fr /tmp/makuLinuxStartTemp/atomConfig.cson ~/.atom/config.cson
	echo "Imported atom settings"

	echo "Disabling terminal case sensitivity..."
	# If ~./inputrc doesn't exist yet, first include the original /etc/inputrc so we don't override it
	if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
	# Add option to ~/.inputrc to enable case-insensitive tab completion
	echo 'set completion-ignore-case On' >> ~/.inputrc
		#Source: https://askubuntu.com/questions/87061/can-i-make-tab-auto-completion-case-insensitive-in-the-terminal
	echo "Disabled terminal case sensitivity!"


	echo "Cleaning up launcher..."
	gsettings set com.canonical.Unity.Launcher favorites "['application://ubiquity.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
	echo "Cleaned up launcher! (Reboot may be necessary)"

	echo "Adding aliases..."
	sudo echo 'alias snip="gnome-screenshot -ac"' >> ~/.bash_aliases
	echo "Added aliases"

	echo "Adding numlockx and enabling numlock on boot..."
	makuInstall numlockx
	sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local
	echo "Added numlockx and enabled numlock on boot!"

	echo "Adding line numbers to Vim..."
	echo "set number" >> ~/.vimrc
	echo "Added line numbers to Vim"

	#echo "Setting Sublime Text as default editor..."
	#sudo sed -i 's/gedit/sublime_text/g' /usr/share/applications/defaults.list
		#Replacing all instances of "gedit" with "sublime_text" in the defaults file
	#echo "Set Sublime Text as default editor!"

	echo "Setting atom as default editor..."
	echo 'export EDITOR="/usr/bin/atom"' >> ~/.bashrc
	source ~/.bashrc
	echo "Set atom as default editor"

	echo "Setting Chromium as default browser..."
	sudo sed -i 's/firefox/chromium/g' /usr/share/applications/defaults.list
	#Should work? Dunno - CHECK
	echo "Set Chromium as default browser!"


	#log "Changing boot settings..."
	#grubFile='/etc/default/grub'
	#grep -i 'GRUB_DEFAULT='


	# log "Importing compizConfig settings..."
	# python /tmp/makuLinuxStartTemp/importCompiz.py '/tmp/makuLinuxStartTemp/compizSettings.profile'
		# #So, it worked when I used this code alone, but it's not working in the script...
	# log "Imported compizConfig settings!"

	updateUpgrade

	sudo apt-get autoremove -y
	echo "Ending here, but I plan on adding more stuff"

}
updateUpgrade()
{
	echo "     Checking for updates..."
	sudo apt-get update -y
	echo "     Attempting updates..."
	sudo apt-get upgrade -y

}
main()
{
	echo "     Preparing for installations"
	preInstallations
	echo "     Preparation complete"

	echo "     Now starting installations"
	performInstallations
	echo "     Installations complete"

	echo "     Changing settings..."
	postInstallations
	echo "     Changing settings complete"

}

if [ $EUID == 0 ]; then
	echo "YOU CANNOT RUN AS ROOT"
fi

mkdir -p /var/tmp/log
log=/var/tmp/log/makuPrepareLinuxLog.log
touch $log

silent=$false
assumeYes=$true
verbose=$false

#Edit these once you know how to do Switches

sudo chown $USER $log
#sudo chown $USER $longLog
main >> $log 2>&1
