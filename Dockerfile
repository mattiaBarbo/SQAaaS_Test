FROM ubuntu:latest

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    docker.io \
    docker-compose \
    python3 \
    python3-pip \
    python3-pytest

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Define the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
