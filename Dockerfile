FROM maven:3.9.6-eclipse-temurin-17 AS builder
COPY pom.xml /workspace/
COPY src /workspace/src
WORKDIR /workspace
RUN mvn -B package -DskipTests=false

FROM ubuntu:22.04
ENV JAVA_VERSION=17

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-${JAVA_VERSION}-jre-headless && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /workspace/target/*-shaded.jar /app/pandemic.jar

# ENTRYPOINT ["sh", "-c", "xvfb-run -s '-screen 0 1024x768x16' java -jar /app/pandemic.jar x11vnc -display :99 -nopw tail -f /dev/null"]
CMD ["java", "-jar", "/app/pandemic.jar"]