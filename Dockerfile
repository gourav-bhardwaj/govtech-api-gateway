FROM openjdk:8-jdk-alpine
ENV ROOTDIR /app
WORKDIR $ROOTDIR
COPY ./build/libs/govtech-api-gateway-0.0.1-SNAPSHOT.jar department-service.jar
#---Created custom group and user so that no buddy can mess with container files-----
RUN addgroup -S govtech && adduser -S govtech -G govtech
USER govtech
#-------------------------------------------------------------------------------------
EXPOSE 8990
ENTRYPOINT ["java", "-jar", "/app/department-service.jar"]
