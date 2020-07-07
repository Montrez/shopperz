FROM openjdk:8
COPY target/shopperz.jar shopperz.jar
EXPOSE 8085
CMD ["/usr/bin/java", "-jar", "/shopperz.jar"]