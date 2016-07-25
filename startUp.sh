#!/bin/bash
module=test
sed -i "s/module/${module}/g" /opt/jetty/bin/jetty.sh
/opt/jetty/bin/jetty.sh start
tailf /dev/null
