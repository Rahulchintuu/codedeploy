# Stage 1: Build with Maven + Java 17
FROM maven:3.8.3-openjdk-17 AS build
WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests -Dmaven.compiler.source=17 -Dmaven.compiler.target=17

# Stage 2: Run on Tomcat 10 + Java 17
FROM tomcat:10-jdk17
WORKDIR /usr/local/tomcat

# Remove default ROOT app
RUN rm -rf webapps/ROOT

# Copy WAR from build stage
COPY --from=build /app/target/*.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
