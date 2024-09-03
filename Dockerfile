FROM maven:3-amazoncorretto-17
COPY target/words.jar .
ENTRYPOINT ["java", "-Xmx8m", "-Xms8m", "-jar", "words.jar"]
EXPOSE 8080
