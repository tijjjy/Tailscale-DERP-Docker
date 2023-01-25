FROM alpine:latest

#Install GO and Tailscale DERPER
RUN apk add go
RUN go install tailscale.com/cmd/derper@main

#Install Tailscale and requirements
RUN apk add curl
RUN apk add iptables

RUN curl https://pkgs.tailscale.com/stable/tailscale_1.36.0_amd64.tgz -o /tmp/tailscale_1.36.0_amd64.tgz
RUN cd /tmp && tar -xvf /tmp/tailscale_1.36.0_amd64.tgz
RUN cp /tmp/tailscale_1.36.0_amd64/tailscaled /usr/sbin/tailscaled
RUN cp /tmp/tailscale_1.36.0_amd64/tailscale /usr/bin/tailscale

#Copy init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 443/tcp
#STUN
EXPOSE 3478/udp

ENTRYPOINT /init.sh