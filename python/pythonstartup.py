#!/usr/bin/env python
import readline
import rlcompleter
import atexit
import os
#tab completion
readline.parse_and_bind('tab: complete')
#history file
historyfile = os.path.join(os.environ['HOME'],'.pythonstartup')
try:
    readline.read_history_file(historyfile)
except:
    pass
atexit.register(readline.write_history_file,historyfile)
del os,historyfile,readline,rlcompleter
