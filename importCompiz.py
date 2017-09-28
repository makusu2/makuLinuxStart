#!/usr/bin/python
import sys
import compizconfig

#The last input on the command line will be the path to save the file to.
savefile=sys.argv[-1]

context=compizconfig.Context()

#saveFile is the name of the file. True specifies whether or not to overwrite current settings.
context.Import(savefile, True)
#Via https://askubuntu.com/questions/244333/compiz-profile-settings-export-and-import-using-command-line