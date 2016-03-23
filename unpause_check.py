#!/usr/bin/python
import sys
from sys import argv
sys.path.append('/var/lib/jenkins/python-pingdom-cli')
import pingdom
script,checkname=argv
#modl = imp.load_source('pingdom', '/home/tarun/backup_script/python-restful-pingdom/pingdom.pyc')
p = pingdom.Pingdom(username='dmittal@intelligrape.com', password='igdefault', appkey='zmtsxbn3jqdqllnnfze15c7uv1no4tu2')
p.unpause_check(checkname)
