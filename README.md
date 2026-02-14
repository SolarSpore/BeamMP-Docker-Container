# BeamMP-Docker-Container
This repository contains a Docker setup for running a **BeamMP server** on Linux with persistent configuration, mods, and logs.

---

## Prerequisites

- Docker installed  
- Linux system (Ubuntu, Pop!_OS, Debian, etc.)  
- Optional: `git` for cloning repositories  

---

## Directory Structure

Persistent data is stored in:

/home/<user>/Containers/BeamMP/
├── config/ # ServerConfig.toml
├── mods/ # Optional mods
└── logs/ # Server logs


---

## Step 1: Clone BeamMP Server

```bash
git clone https://github.com/BeamMP/BeamMP-Server.git ~/BeamMP-Server
cd ~/BeamMP-Server
Step 2: Download Server Binary
wget https://github.com/BeamMP/BeamMP-Server/releases/download/v3.9.0/BeamMP-Server.debian.12.x86_64
chmod +x BeamMP-Server.debian.12.x86_64
Step 3: Create Config Directory and Copy Config
mkdir -p ~/Containers/BeamMP/config
cp ServerConfig.toml ~/Containers/BeamMP/config/
Make sure to edit ServerConfig.toml and add your AuthKey.

Step 4: Dockerfile
FROM debian:12-slim

# Install dependencies
RUN apt-get update && apt-get install -y liblua5.3-0 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /beammp

# Copy server binary
COPY BeamMP-Server.debian.12.x86_64 ./BeamMP-Server

# Copy config folder
COPY config ./config

# Make binary executable
RUN chmod +x BeamMP-Server

# Start server
CMD ["./BeamMP-Server"]
Step 5: Build Docker Image
docker build -t beammp-server .
Step 6: Run Container
docker run -d \
  --name beammp-server \
  --restart unless-stopped \
  -p 50000:50000/tcp \
  -p 51000:51000/udp \
  -v ~/Containers/BeamMP/config:/beammp/config \
  -v ~/Containers/BeamMP/mods:/beammp/mods \
  -v ~/Containers/BeamMP/logs:/beammp/log
