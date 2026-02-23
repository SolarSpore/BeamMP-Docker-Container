# BeamMP Docker Container

A simple Docker setup for running a self-hosted [BeamMP](https://beammp.com/) multiplayer server on Linux with persistent config, mods, and logs. Tested on Ubuntu, Pop!_OS, and Debian.

---

## Prerequisites

- Docker installed on your system
- A Linux machine (Ubuntu, Pop!_OS, Debian, etc.)
- A BeamMP Auth Key — grab one from the [BeamMP Keymaster](https://keymaster.beammp.com/)
- `git` (optional, for cloning)

---

## Directory Structure

Persistent data lives on your host machine at:

```
/home/<user>/Containers/BeamMP/
├── config/     # ServerConfig.toml goes here
├── mods/       # Drop server-side mods here
└── logs/       # Server logs end up here
```

Volumes are mounted into the container at runtime, so your config and mods survive container rebuilds.

---

## Setup

### 1. Clone the BeamMP Server repo

```bash
git clone https://github.com/BeamMP/BeamMP-Server.git ~/BeamMP-Server
cd ~/BeamMP-Server
```

### 2. Download the server binary

```bash
wget https://github.com/BeamMP/BeamMP-Server/releases/download/v3.9.0/BeamMP-Server.debian.12.x86_64
chmod +x BeamMP-Server.debian.12.x86_64
```

### 3. Set up your config

```bash
mkdir -p ~/Containers/BeamMP/config
cp ServerConfig.toml ~/Containers/BeamMP/config/
```

> **Important:** Open `~/Containers/BeamMP/config/ServerConfig.toml` and paste in your `AuthKey` before building or running anything.

---

## Dockerfile

```dockerfile
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
```

---

## Build & Run

### Build the image

```bash
docker build -t beammp-server .
```

### Run the container

```bash
docker run -d \
  --name beammp-server \
  --restart unless-stopped \
  -p 50000:50000/tcp \
  -p 51000:51000/udp \
  -v ~/Containers/BeamMP/config:/beammp/config \
  -v ~/Containers/BeamMP/mods:/beammp/mods \
  -v ~/Containers/BeamMP/logs:/beammp/logs \
  beammp-server
```

The server will start in the background and restart automatically if it crashes or if Docker restarts.

```

---

## Notes & Troubleshooting

- If you see a **"No config file found"** error, double-check that your volume mounts are correct and that `ServerConfig.toml` actually exists in `~/Containers/BeamMP/config/`.
- Mods placed in `~/Containers/BeamMP/mods/` will be served to connecting clients automatically.
- Server logs are written to `~/Containers/BeamMP/logs/` and persist between restarts.
- To update the server binary in the future, just download the new release, rebuild the image, and restart the container.
