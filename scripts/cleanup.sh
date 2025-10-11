#!/bin/bash
echo "======== Cleaning up previous deployment ========"
sudo systemctl stop tomcat || true
sudo rm -rf /usr/share/tomcat/webapps/Ecomm*
sudo rm -rf /usr/share/tomcat/work/Catalina/localhost/Ecomm
echo "Cleanup completed"
