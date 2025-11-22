# Use Java 8 as the base image since Barefoot requires Java version 7 or higher
FROM openjdk:8

# Install Maven, which is required for building the Barefoot JAR
RUN apt-get update && \
    apt-get install -y maven

# Copy the Barefoot source code into the container
COPY . /barefoot

# Set the working directory to the Barefoot directory
WORKDIR /barefoot

# Package Barefoot JAR (including dependencies and executable main class)
RUN mvn package -DskipTests

# Expose the port that the matcher server will run on
EXPOSE 1234

ARG VERSION
ARG REGION

# Command to start the matcher server with standard configuration for map server and map matching
# Note: Replace <VERSION> with the actual version number of Barefoot
CMD java -jar target/barefoot-${VERSION}-matcher-jar-with-dependencies.jar --geojson config/server.properties config/${REGION}.properties

