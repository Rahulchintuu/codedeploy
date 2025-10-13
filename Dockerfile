# -------- Stage 1: Build with Maven using Java 11 --------
FROM maven:3.8.3-openjdk-11 AS build
WORKDIR /app

# Copy Maven settings for private repos (if needed)
# COPY settings.xml /root/.m2/settings.xml

# Copy project files
COPY . .

# Build project (skip tests for faster builds)
RUN mvn clean package -DskipTests -Dmaven.compiler.source=11 -Dmaven.compiler.target=11

# -------- Stage 2: Run on Tomcat 7 --------
FROM tomcat:7.0.109-jdk11
WORKDIR /usr/local/tomcat

# Remove default ROOT app
RUN rm -rf webapps/ROOT

# Copy WAR from build stage
COPY --from=build /app/target/*.war webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
