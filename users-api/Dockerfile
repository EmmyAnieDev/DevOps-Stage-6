FROM maven:3.8-eclipse-temurin-8-alpine AS build

WORKDIR /app

COPY pom.xml .

ENV MAVEN_OPTS="-Dhttps.protocols=TLSv1.2"

RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

FROM eclipse-temurin:8-jre-alpine

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8083

CMD ["java", "-jar", "app.jar"]