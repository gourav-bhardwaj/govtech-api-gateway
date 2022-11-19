#-----i) OpenJDK with proper version
FROM openjdk:8-jdk-alpine 
ENV ROOTDIR /app
WORKDIR $ROOTDIR
COPY ./build/libs/govtech-api-gateway-*-SNAPSHOT.jar govtech-api-gateway.jar
#-----ii) Health check of docker container 
HEALTHCHECK --interval=32s --timeout=4s CMD curl -f http://localhost:8990/actuator/health/liveness || exit 1
#-----iii) Created custom group and user so that no buddy can mess with container files-----
ARG USER='govtech'
RUN addgroup -S ${USER} && adduser -S ${USER} -u 1019 -G ${USER}
USER ${USER}
#-------------------------------------------------------------------------------------
EXPOSE 8990
ENTRYPOINT ["java", "-jar", "/app/govtech-api-gateway.jar"]
