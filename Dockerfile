# Use a small Debian base image
FROM debian:12-slim

# Install Lua dependency
RUN apt-get update && apt-get install -y liblua5.3-0 && rm -rf /var/lib/apt/lists/*

# Set working directory inside the container
WORKDIR /beammp

# Copy server binary
COPY BeamMP-Server.debian.12.x86_64 ./BeamMP-Server

# Copy config folder (optional, keeps default settings)
COPY config ./config

# Make binary executable
RUN chmod +x BeamMP-Server

# Expose server ports
EXPOSE 30814/tcp 30814/udp

# Set volumes for persistence
VOLUME ["/beammp/config", "/beammp/mods", "/beammp/logs"]

# Run the server
CMD ["./BeamMP-Server"]
