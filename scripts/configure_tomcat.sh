
#!/bin/bash
set -e

TOMCAT_DIR="/opt/tomcat"
TOMCAT_USER="ec2-user"

echo "======== Configuring Tomcat Manager and Users ========="

# Create tomcat-users.xml with manager access
sudo cat > /home/ec2-user/tomcat-users.xml << 'EOF'
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

# Copy to Tomcat conf directory
sudo cp /home/ec2-user/tomcat-users.xml $TOMCAT_DIR/conf/
sudo chown $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/conf/tomcat-users.xml
sudo chmod 644 $TOMCAT_DIR/conf/tomcat-users.xml

echo "✓ tomcat-users.xml configured"

# Enable manager access by modifying context.xml (if manager app exists)
MANAGER_CONTEXT="$TOMCAT_DIR/webapps/manager/META-INF/context.xml"
if [ -f "$MANAGER_CONTEXT" ]; then
    sudo sed -i '/RemoteAddrValve/d' "$MANAGER_CONTEXT"
    echo "✓ Manager access enabled"
else
    echo "ℹ Manager app not found, skipping context modification"
fi

# Create necessary directories
sudo mkdir -p $TOMCAT_DIR/temp
sudo mkdir -p $TOMCAT_DIR/logs
sudo mkdir -p $TOMCAT_DIR/work
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/temp
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/logs
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/work

echo "✓ Directories created and permissions set"

# Configure Tomcat to listen on all interfaces (optional)
SERVER_XML="$TOMCAT_DIR/conf/server.xml"
if [ -f "$SERVER_XML" ]; then
    sudo sed -i 's/Connector port="8080"/Connector port="8080" address="0.0.0.0"/' "$SERVER_XML"
    echo "✓ Tomcat configured to listen on all interfaces"
fi

echo "======== Tomcat configuration completed ========="
