#!/bin/bash
set -e
TOMCAT_VERSION=9.0.88
TOMCAT_DIR=/opt/tomcat
TOMCAT_USER="ec2-user"

echo "======== Updating system ========="
sudo yum update -y

echo "======== Installing Java 11 ========="
if ! java -version &>/dev/null; then
  sudo yum install -y java-11-amazon-corretto
fi

JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "Detected JAVA_HOME=$JAVA_HOME_PATH"

echo "======== Installing Tomcat ========="
if [ ! -d "$TOMCAT_DIR" ]; then
    sudo curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
    sudo tar -xzf apache-tomcat-$TOMCAT_VERSION.tar.gz
    sudo mv apache-tomcat-$TOMCAT_VERSION tomcat
    sudo chmod +x $TOMCAT_DIR/bin/*.sh
    sudo chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR
fi

echo "======== Creating Tomcat systemd service ========="
if [ ! -f /etc/systemd/system/tomcat.service ]; then
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_USER

Environment=JAVA_HOME=$JAVA_HOME_PATH
Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR

ExecStart=$TOMCAT_DIR/bin/startup.sh
ExecStop=$TOMCAT_DIR/bin/shutdown.sh

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
fi
