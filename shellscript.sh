#!/bin/bash

function configureTomcatManager() {

        echo "Configuring Tomcat Manager access..."

        sed -i 's|allow="[^"]"|allow="."|' /opt/tomcat/webapps/manager/META-INF/context.xml



#sed = stream editor, used here to search and replace text inside a file.

#-i    = in-place edit (the file is directly modified).



#'s|allow="[^"]*"|allow=".*"|' = this is the substitution pattern

#allow =    "[^"]*" → matches the current allow attribute(which by default only allows 127.0.0.1 and ::1).



#allow=     ".*" → replaces it with a wildcard that allows  any IP address.

#File being edited: context.xml of the Manager web app.



        sed -i 's|allow="[^"]"|allow="."|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# File being edited: context.xml of the Host-Manager webApp



#By default, both Manager and Host Manager apps are locked to #localhost for security. Without this step, you cannot access #them from your EC2 instance’s public IP. This script automates #the manual edit by replacing the restrictive allow rule with a #universal one.



        echo "Manager access updated."

}

function showAccessURL() {

# Fetch public IP
        PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

        if [ -n "$PUBLIC_IP" ]; then
                echo "🌐 Access your Tomcat server at:"
                echo "👉 http://$PUBLIC_IP:8080"
        else
                echo "⚠️ Unable to fetch public IP. Please check internet connectivity."
        fi


}

function startTomcat() {

        if netstat -lntp 2>/dev/null | grep ":8080 " >/dev/null; then

                echo "Tomcat Server is already running."

        else
                echo "Starting Tomcat..."

                 sh /opt/tomcat/bin/startup.sh
                 echo "Tomcat started."

                 showAccessURL

fi

}

function stopTomcat() {

        if netstat -lntp 2>/dev/null | grep ":8080 " >/dev/null; then

                echo "Stopping Tomcat..."

                sh /opt/tomcat/bin/shutdown.sh

                echo "Tomcat stopped."

        else

                echo "Tomcat is not running."


        fi
}
function cloneRepo() {
        read -p "Enter directory for repo: " myrepo
        mkdir -p "$myrepo"
        cd "$myrepo" || exit
        git clone https://github.com/Rahulchintuu/codedeploy.git

}

function appDeploy() {
        if [ -f /opt/$myrepo/codedeploy/pom.xml ]; then
                echo "Build file exists. Running Maven package..."
                cd /opt/$myrepo/codedeploy || exit
                mvn package
                cp target/Ecomm.war /opt/tomcat/webapps/
                echo "Deployment complete."
                APP_DEPLOYED=true
                showAccessURL

        else
                echo "Build file does not exist."
        fi

}

function undeployApp() {
        if [ -f /opt/tomcat/webapps/Ecomm.war ] || [ -d /opt/tomcat/webapps/Ecomm ]; then
                echo "Undeploying Application..."
                rm -f /opt/tomcat/webapps/Ecomm.war
                rm -rf /opt/tomcat/webapps/Ecomm
                APP_DEPLOYED=false
        else
                echo "⚠️ No application deployed yet, cannot undeploy."
        fi
}
while true;
do

        echo "" echo "========== Tomcat Menu =========="
        echo "1. Configure Tomcat Manager"
        echo "2. Start Tomcat"
        echo "3. Stop Tomcat"
        echo "4. Clone Repo"
        echo "5. Deploy App"
        echo "6. UndeployApp"
        echo "7. Exit" echo "================================="
        read -p "Select option [1-7]: " option

        case $option in
                1) configureTomcatManager ;;
                2) startTomcat ;;
                3) stopTomcat ;;
                4) cloneRepo ;;
                5) appDeploy ;;
                6) undeployApp ;;
                7) echo "Exiting..."; break ;;
                *) echo "Please select a valid option." ;;
        esac
done
