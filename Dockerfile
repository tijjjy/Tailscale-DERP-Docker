# Use Ubuntu as the base image for the builder
FROM ubuntu:latest AS builder

LABEL org.opencontainers.image.source https://github.com/tijjjy/Tailscale-DERP-Docker

# Install dependencies and the latest Go
RUN apt-get update && \
    apt-get install -y wget tar && \
    wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz && \
    tar -xvf go1.21.4.linux-amd64.tar.gz && \
    mv go /usr/local && \
    rm -rf /var/lib/apt/lists/*

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"

# Install Tailscale DERPER
RUN go install tailscale.com/cmd/derper@main

# Use Ubuntu as the final base image
FROM ubuntu:latest

# Install Tailscale requirements
RUN apt-get update && \
    apt-get install -y curl iptables && \
    rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create the necessary directory and copy the derper binary
RUN mkdir -p /root/go/bin
COPY --from=builder /root/go/bin/derper /root/go/bin/derper

# Copy and set permissions for the init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

# Derper Web Ports
EXPOSE 80
EXPOSE 443/tcp
# STUN
EXPOSE 3478/udp

ENTRYPOINT ["/init.sh"]

