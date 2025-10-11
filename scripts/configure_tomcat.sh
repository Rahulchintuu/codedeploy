#!/bin/bash
set -e

TOMCAT_DIR="/opt/tomcat"
TOMCAT_USER="tomcat"

echo "======== Configuring Tomcat Manager and Users ========="

# Create tomcat-users.xml directly (don't rely on copied file)
sudo cat > $TOMCAT_DIR/conf/tomcat-users.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <role rolename="manager-jmx"/>
    <role rolename="manager-status"/>
    <role rolename="admin-gui"/>
    <role rolename="admin-script"/>
    <user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-gui,admin-script"/>
</tomcat-users>
EOF

# Set proper permissions
sudo chown $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/conf/tomcat-users.xml
sudo chmod 644 $TOMCAT_DIR/conf/tomcat-users.xml

echo "✓ tomcat-users.xml created and configured"

# Enable manager access by modifying context.xml
MANAGER_CONTEXT="$TOMCAT_DIR/webapps/manager/META-INF/context.xml"
if [ -f "$MANAGER_CONTEXT" ]; then
    sudo sed -i '/RemoteAddrValve/d' "$MANAGER_CONTEXT"
    echo "✓ Manager access enabled"
else
    echo "ℹ Manager app not found, downloading manager webapp..."
    # Download and install manager app
    sudo wget -P $TOMCAT_DIR/webapps/ https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.65/bin/extras/catalina-jmx-remote.jar || true
fi

# Create necessary directories
sudo mkdir -p $TOMCAT_DIR/temp
sudo mkdir -p $TOMCAT_DIR/logs
sudo mkdir -p $TOMCAT_DIR/work
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/temp
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/logs
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/work

echo "✓ Directories created and permissions set"

# Configure Tomcat to listen on all interfaces
SERVER_XML="$TOMCAT_DIR/conf/server.xml"
if [ -f "$SERVER_XML" ]; then
    sudo sed -i 's/Connector port="8080"/Connector port="8080" address="0.0.0.0"/' "$SERVER_XML"
    echo "✓ Tomcat configured to listen on all interfaces"
fi

echo "======== Tomcat configuration completed ========="
