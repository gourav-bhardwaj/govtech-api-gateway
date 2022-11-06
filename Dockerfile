#-----i) OpenJDK with proper version
FROM openjdk:8-jdk-alpine 
ENV ROOTDIR /app
WORKDIR $ROOTDIR
COPY ./build/libs/govtech-api-gateway-0.0.1-SNAPSHOT.jar department-service.jar
#-----ii) Health check of docker container 
HEALTHCHECK --interval=32s --timeout=4s CMD curl -f http://localhost:8990/actuator/health/liveness || exit 1
#-----iii) Created custom group and user so that no buddy can mess with container files-----
ARG USER='govtech'
RUN addgroup -S ${USER} && adduser -S ${USER} -G ${USER}
USER ${USER}
#-------------------------------------------------------------------------------------
EXPOSE 8990
ENTRYPOINT ["java", "-jar", "/app/department-service.jar"]
