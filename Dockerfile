FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY target/achat-1.0.jar achat.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "achat.jar"]

