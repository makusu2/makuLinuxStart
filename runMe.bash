#!/usr/bin/env bash
#Steven
#Maku
#If permission denied, do chmod +x makuPrepareLinux.bash
sudo apt-get install -y git > /dev/null && git-clone -q https://github.com/makusu2/makuLinuxStart.git /tmp/makuLinuxStartTemp && sudo bash /tmp/makuLinuxStartTemp/makuPrepareLinux.bash