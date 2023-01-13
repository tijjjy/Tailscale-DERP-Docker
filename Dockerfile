FROM alpine:latest

#Install GO and Tailscale DERPER
RUN apk add go
RUN go install tailscale.com/cmd/derper@main

#Install Tailscale and requirements
RUN apk add openrc
RUN apk add curl
RUN curl -fsSL https://tailscale.com/install.sh | sh

#Copy init script
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 443/tcp
#STUN
EXPOSE 3478/udp

ENTRYPOINT /init.sh