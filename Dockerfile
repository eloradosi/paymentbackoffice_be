# Stage 1: Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy Maven wrapper and pom.xml
COPY mvnw.cmd .
COPY pom.xml .
COPY .mvn .mvn

# Download dependencies (cache layer)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the built application from build stage
COPY --from=build /app/target/quarkus-app/lib/ /app/lib/
COPY --from=build /app/target/quarkus-app/*.jar /app/
COPY --from=build /app/target/quarkus-app/app/ /app/app/
COPY --from=build /app/target/quarkus-app/quarkus/ /app/quarkus/

# Expose port
EXPOSE 8080

# Set environment variables
ENV JAVA_OPTS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"
ENV JAVA_APP_JAR="/app/quarkus-run.jar"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/q/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "/app/quarkus-run.jar"]
