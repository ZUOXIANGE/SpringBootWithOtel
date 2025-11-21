FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests package
ARG OTEL_AGENT_VERSION=2.6.0
RUN curl -fsSL https://repo1.maven.org/maven2/io/opentelemetry/javaagent/opentelemetry-javaagent/${OTEL_AGENT_VERSION}/opentelemetry-javaagent-${OTEL_AGENT_VERSION}.jar -o /app/opentelemetry-javaagent.jar

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/todo-otel-openobserve-0.0.1-SNAPSHOT.jar /app/app.jar
COPY --from=build /app/opentelemetry-javaagent.jar /otel/opentelemetry-javaagent.jar
EXPOSE 8080
ENTRYPOINT ["java","-javaagent:/otel/opentelemetry-javaagent.jar","-jar","/app/app.jar"]