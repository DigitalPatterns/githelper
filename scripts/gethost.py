#!/usr/bin/env python
import os
import sys
from giturlparse import parse

resource = parse(sys.argv[1]).resource
port = parse(sys.argv[1]).port

os.system("ssh-keyscan -T 10 -p %s %s >> /home/user1/.ssh/known_hosts" % (port, resource))
