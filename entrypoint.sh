#!/bin/bash
set -e

# Create Docker volumes
docker volume create neo4j_data_test
docker volume create neo4j_logs_test
docker volume create yprov_data_test

# Create Docker network
docker network create yprov_net_test

# Start Neo4j service
docker run \
  --name db_test \
  --network=yprov_net_test \
  -p 7474:7474 -p 7687:7687 \
  -d \
  -v neo4j_data_test:/data \
  -v neo4j_logs_test:/logs \
  -v $HOME/neo4j/import:/var/lib/neo4j/import \
  -v $HOME/neo4j/plugins:/plugins \
  --env NEO4J_AUTH=neo4j/password \
  --env NEO4J_ACCEPT_LICENSE_AGREEMENT=eval \
  -e NEO4J_apoc_export_file_enabled=true \
  -e NEO4J_apoc_import_file_enabled=true \
  -e NEO4J_apoc_import_file_use__neo4j__config=true \
  -e NEO4J_PLUGINS='["apoc"]' \
  neo4j:enterprise

# Start API service
docker run \
  --restart on-failure \
  --name web_test \
  --network=yprov_net_test \
  -p 3000:3000 \
  -d \
  -v yprov_data_test:/app/conf \
  --env USER=neo4j \
  --env PASSWORD=password \
  hpci/yprov:latest

echo "Checking logs of web_test service..."
docker logs web_test

# Wait for API to be ready
echo "Waiting for API to be ready..."
max_attempts=15
attempt=0
until [ $attempt -ge $max_attempts ]
do
  if curl -s -o /dev/null -w "%{http_code}" http://host.docker.internal:3000/api/v0/documents | grep -q "200"; then
    echo "API is ready!"
    break
  fi
  attempt=$((attempt+1))
  echo "Attempt $attempt/$max_attempts: API is not ready yet. Waiting..."
  sleep 10
done

# Run tests
python3 -m pytest -v

# Quality Tests (dummy step as the actual action cannot be executed directly)
echo "Running Quality Tests..."
# Placeholder for quality test script

# Clean up
docker stop web_test
docker rm web_test
docker stop db_test
docker rm db_test
docker network rm yprov_net_test
docker volume rm neo4j_data_test
docker volume rm neo4j_logs_test
docker volume rm yprov_data_test
