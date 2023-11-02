FROM alpine:latest AS builder

LABEL org.opencontainers.image.source https://github.com/tijjjy/Tailscale-DERP-Docker

#Install Tailscale and requirements
RUN apk add curl iptables

#Install GO and Tailscale DERPER
RUN apk add go --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN go install tailscale.com/cmd/derper@main

FROM alpine:latest

#Install Tailscale and Tailscaled
RUN apk add tailscale --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

RUN mkdir -p /root/go/bin
COPY --from=builder /root/go/bin/derper /root/go/bin/derper

#Copy init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

#Derper Web Ports
EXPOSE 80
EXPOSE 443/tcp
#STUN
EXPOSE 3478/udp

ENTRYPOINT /init.sh
