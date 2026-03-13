FROM maven:3.9-eclipse-temurin-11 AS build

WORKDIR /workspace
COPY pom.xml ./
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:11-jre-alpine

RUN addgroup -S app && adduser -S app -G app && apk add --no-cache wget
USER app
WORKDIR /app
EXPOSE 3009
COPY --from=build /workspace/target/java-service.jar /app/java-service.jar
ENTRYPOINT ["java", "-jar", "/app/java-service.jar"]
