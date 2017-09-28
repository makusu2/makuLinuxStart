#!/usr/bin/python
import sys, os
import compizconfig

#The last input on the command line will be the path to save the file to.
savefile=sys.argv[-1]

context=compizconfig.Context()
context.Import('/tmp/makuLinuxStartTemp/compizSettings.profile')

#Via https://askubuntu.com/questions/244333/compiz-profile-settings-export-and-import-using-command-line