#!/bin/bash
set -e

# Create Docker volumes if not exist
if [ "$(docker volume ls -q -f name=neo4j_data)" == "" ]; then
  docker volume create neo4j_data
fi

if [ "$(docker volume ls -q -f name=neo4j_logs)" == "" ]; then
  docker volume create neo4j_logs
fi

if [ "$(docker volume ls -q -f name=yprov_data)" == "" ]; then
  docker volume create yprov_data
fi

# Create Docker network if not exist
if [ "$(docker network ls -q -f name=yprov_net)" == "" ]; then
  docker network create yprov_net
fi

# Start Neo4j service
docker run \
  --name db \
  --network=yprov_net \
  -p 7474:7474 -p 7687:7687 \
  -d \
  -v neo4j_data:/data \
  -v neo4j_logs:/logs \
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
  --name web \
  --network=yprov_net \
  -p 3000:3000 \
  -d \
  -v yprov_data:/app/conf \
  --env USER=neo4j \
  --env PASSWORD=password \
  hpci/yprov:latest

docker network connect yprov_net unittests

# Wait for Neo4j to be ready
echo "Waiting for Neo4j to be ready..."
for i in {1..15}; do
    if curl -s http://db:7474 > /dev/null; then
        echo "Neo4j is ready!"
        break
    fi
    echo "Attempt $i/15: Neo4j is not ready yet. Waiting..."
    sleep 10
done

# Wait for the API to be ready
echo "Waiting for API to be ready..."
for i in {1..15}; do
    if curl -s http://web:3000/api/v0/documents > /dev/null; then
        echo "API is ready!"
        break
    fi
    echo "Attempt $i/15: API is not ready yet. Waiting..."
    sleep 10
done

# Run tests
python3 -m pytest -v

# Quality Tests (dummy step as the actual action cannot be executed directly)
echo "Running Quality Tests..."
# Placeholder for quality test script

# Clean up
docker stop web
docker rm web
docker stop db
docker rm db
docker network rm yprov_net
docker volume rm neo4j_data
docker volume rm neo4j_logs
docker volume rm yprov_data
