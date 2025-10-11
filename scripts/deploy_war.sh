#!/bin/bash
set -e

echo "======== Deploying WAR file ========"

TOMCAT_DIR="/opt/tomcat"

# Stop Tomcat before deployment
sudo systemctl stop tomcat

# Wait for Tomcat to stop
sleep 5

# Clean previous deployment
sudo rm -rf $TOMCAT_DIR/webapps/Ecomm*
sudo rm -rf $TOMCAT_DIR/work/Catalina/localhost/Ecomm

# Deploy WAR file
sudo cp target/Ecomm.war $TOMCAT_DIR/webapps/
sudo chown tomcat:tomcat $TOMCAT_DIR/webapps/Ecomm.war
sudo chmod 755 $TOMCAT_DIR/webapps/Ecomm.war

echo "✓ WAR file deployed to $TOMCAT_DIR/webapps/Ecomm.war"
