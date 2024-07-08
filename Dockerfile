# Usa un'immagine di base preesistente
FROM python:3.9-slim

# Installa le dipendenze del sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    docker.io \
    docker-compose

# Crea una directory di lavoro nell'immagine
WORKDIR /app

# Copia il file requirements.txt dalla cartella clonata
COPY requirements.txt /app/requirements.txt

# Installa le dipendenze Python specificate in requirements.txt
RUN pip install -r requirements.txt

# Copia lo script entrypoint.sh dalla cartella clonata
COPY entrypoint.sh /app/entrypoint.sh

# Rendi eseguibile lo script entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Esegui lo script entrypoint.sh come entrypoint del container
ENTRYPOINT ["/app/entrypoint.sh"]
