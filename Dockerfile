FROM openjdk:17-alpine as builder
RUN apk update && apk add --no-cache maven git
WORKDIR /opt/app
RUN cd /opt/app && git clone https://github.com/edumqes/AvaliacaoCloudMinsait AvaliacaoCloudMinsait
RUN cd /opt/app/AvaliacaoCloudMinsait && mvn clean test dependency:copy-dependencies install -DskipTests 
RUN cp /opt/app/AvaliacaoCloudMinsait/target/dependency/* /opt/app/.
FROM openjdk:17-alpine
ARG APPLICATION_USER=appuser
RUN adduser --no-create-home -u 1000 -D $APPLICATION_USER
# Configure working directory
RUN mkdir /app && \
    chown -R $APPLICATION_USER /app
USER 1000
COPY --chown=1000:1000 --from=builder /opt/app/AvaliacaoCloudMinsait/target/minsait-0.0.1-SNAPSHOT.jar  /app/app.jar
COPY --chown=1000:1000 --from=builder /opt/app/*.jar /app/.
WORKDIR /app
EXPOSE 8080
ENTRYPOINT [ "java", "-jar", "/app/app.jar" ]