FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io \
    docker-compose

# Work Directory
WORKDIR /app

# Clean and clone updated GitHub repo
RUN rm -rf /app/* && \
    git clone https://github.com/mattiaBarbo/SQAaaS_Test.git .
    
# Install requirements
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Make the script.sh script executable and run it
COPY script.sh /app/script.sh
RUN chmod +x /app/script.sh
ENTRYPOINT ["/app/script.sh"]