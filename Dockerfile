FROM openjdk:8-jdk-alpine
ENV ROOTDIR /app
WORKDIR $ROOTDIR
COPY ./build/libs/govtech-api-gateway-0.0.1-SNAPSHOT.jar department-service.jar
EXPOSE 8990
ENTRYPOINT ["java", "-jar", "/app/department-service.jar"]