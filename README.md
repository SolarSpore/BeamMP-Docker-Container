# BeamMP Docker Container

A simple Docker setup for running a self-hosted [BeamMP](https://beammp.com/) multiplayer server on Linux (or Windows via WSL2) with persistent config, mods, and logs. Tested on Ubuntu, Pop!_OS, and Debian.

---

## Prerequisites

- Docker installed on your system
- A BeamMP Auth Key — grab one from the [BeamMP Keymaster](https://keymaster.beammp.com/)
- `git` (optional, for cloning)

**Windows users:** See the [Windows Setup](#windows-setup-wsl2) section below before continuing.

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

## Windows Setup (WSL2)

If you're on Windows, the easiest path is running this through Docker Desktop with WSL2. This lets you use the same Linux commands as everyone else.

### 1. Install WSL2

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your machine when prompted. This installs WSL2 with Ubuntu by default.

### 2. Install Docker Desktop

Download and install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/). During setup, make sure **"Use WSL2 instead of Hyper-V"** is selected.

Once installed, open Docker Desktop → Settings → Resources → WSL Integration, and enable it for your Ubuntu distro.

### 3. Open your WSL terminal

Launch Ubuntu from the Start menu (or run `wsl` in PowerShell). From here, all the steps below are identical to Linux — just follow along normally.

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

### Option A — Docker Compose (recommended)

Create a `docker-compose.yml` in your project folder:

```yaml
services:
  beammp-server:
    image: beammp-server
    container_name: beammp-server
    restart: unless-stopped
    ports:
      - "50000:50000/tcp"
      - "51000:51000/udp"
    volumes:
      - ~/Containers/BeamMP/config:/beammp/config
      - ~/Containers/BeamMP/mods:/beammp/mods
      - ~/Containers/BeamMP/logs:/beammp/logs
```

Then start it with:

```bash
docker compose up -d
```

To stop it:

```bash
docker compose down
```

### Option B — Docker Run

If you'd rather skip the compose file, you can run it directly:

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

---

## Notes & Troubleshooting

- If you see a **"No config file found"** error, double-check that your volume mounts are correct and that `ServerConfig.toml` actually exists in `~/Containers/BeamMP/config/`.
- Mods placed in `~/Containers/BeamMP/mods/` will be served to connecting clients automatically.
- Server logs are written to `~/Containers/BeamMP/logs/` and persist between restarts.
- To update the server binary in the future, just download the new release, rebuild the image, and restart the container.
- **Windows users:** Make sure Docker Desktop is running before using any `docker` commands in WSL.
