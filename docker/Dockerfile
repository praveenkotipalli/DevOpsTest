# Multi-stage build for production-grade Docker image
FROM openjdk:17-jdk-slim AS builder

# Set working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy Maven wrapper and pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Make Maven wrapper executable
RUN chmod +x mvnw

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests

# Production stage
FROM openjdk:17-jre-slim AS production

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install necessary packages for production
RUN apt-get update && apt-get install -y \
    curl \
    dumb-init \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set working directory
WORKDIR /app

# Create necessary directories
RUN mkdir -p /app/logs /app/config /app/temp \
    && chown -R appuser:appuser /app

# Copy JAR file from builder stage
COPY --from=builder --chown=appuser:appuser /app/target/*.jar app.jar

# Copy configuration files
COPY --chown=appuser:appuser docker/application.yml /app/config/
COPY --chown=appuser:appuser docker/logback-spring.xml /app/config/

# Set environment variables
ENV JAVA_OPTS="-Xms512m -Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication"
ENV SPRING_PROFILES_ACTIVE="production"
ENV TZ="UTC"

# Expose ports
EXPOSE 8080 9090

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar --spring.config.location=file:/app/config/application.yml"]

# Labels for better image management
LABEL maintainer="devops-team@example.com"
LABEL version="1.0.0"
LABEL description="Sample Application for Production DevOps Pipeline"
LABEL org.opencontainers.image.source="https://github.com/example/sample-app"
LABEL org.opencontainers.image.vendor="Example Corp"
LABEL org.opencontainers.image.licenses="MIT"
