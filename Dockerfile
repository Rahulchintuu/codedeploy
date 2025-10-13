# -------- Stage 1: Build with Maven using JDK 17 --------
FROM maven:3.8.3-openjdk-17 AS build
WORKDIR /app

# Copy all project files
COPY . .

# Build the project with Java 17
RUN mvn clean package -DskipTests -Dmaven.compiler.source=17 -Dmaven.compiler.target=17 -X

# -------- Stage 2: Run on Tomcat using JDK 17 --------
FROM tomcat:10-jdk17
WORKDIR /usr/local/tomcat

# Copy WAR file from build stage
COPY --from=build /app/target/*.war webapps/ROOT.war

# Expose default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
