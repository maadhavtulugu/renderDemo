# Stage 1: Build
FROM eclipse-temurin:21-jdk-alpine AS build

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml first for caching dependencies
COPY mvnw .
COPY .mvn/ .mvn
COPY pom.xml .

# Make mvnw executable (important for Linux)
RUN chmod +x mvnw

# Download dependencies offline to speed up rebuilds
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application (skip tests to speed up)
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:21-jdk-alpine

# Set working directory
WORKDIR /app

# Copy the built jar from the build stage (correct JAR name)
COPY --from=build /app/target/renderDemo-0.0.1-SNAPSHOT.jar app.jar

# Expose port 8080
EXPOSE 8080

# Command to run the Spring Boot app
CMD ["java", "-jar", "app.jar"]
