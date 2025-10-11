#!/bin/bash
set -e

echo "======== Deploying WAR file ========"

TOMCAT_DIR="/opt/tomcat"

# Stop Tomcat before deployment
sudo systemctl stop tomcat || true

# Wait for Tomcat to stop
sleep 5

# Clean previous deployment
sudo rm -rf $TOMCAT_DIR/webapps/Ecomm*
sudo rm -rf $TOMCAT_DIR/work/Catalina/localhost/Ecomm

# Look for WAR file in common locations
if [ -f "/opt/target/Ecomm.war" ]; then
    WAR_FILE="/opt/target/Ecomm.war"
elif [ -f "target/Ecomm.war" ]; then
    WAR_FILE="target/Ecomm.war"
elif [ -f "/home/ec2-user/target/Ecomm.war" ]; then
    WAR_FILE="/home/ec2-user/target/Ecomm.war"
else
    # Search for the file
    WAR_FILE=$(find /home/ec2-user -name "Ecomm.war" -type f 2>/dev/null | head -1)
fi

if [ -n "$WAR_FILE" ] && [ -f "$WAR_FILE" ]; then
    echo "✓ Found WAR file at: $WAR_FILE"
    
    # Deploy WAR file
    sudo cp "$WAR_FILE" $TOMCAT_DIR/webapps/
    sudo chown tomcat:tomcat $TOMCAT_DIR/webapps/Ecomm.war
    sudo chmod 755 $TOMCAT_DIR/webapps/Ecomm.war
    
    echo "✓ WAR file deployed to $TOMCAT_DIR/webapps/Ecomm.war"
else
    echo "❌ ERROR: WAR file not found!"
    echo "Searching for any WAR files:"
    find /home/ec2-user -name "*.war" -type f 2>/dev/null
    find /opt -name "*.war" -type f 2>/dev/null
    exit 1
fi
