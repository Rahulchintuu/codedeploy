# -------- Stage 1: Build with Maven --------
FROM maven:3.8.6-jdk-11 AS build
WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

# -------- Stage 2: Run on Tomcat --------
FROM tomcat:9-jdk11
WORKDIR /usr/local/tomcat

COPY --from=build /app/target/*.war webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
