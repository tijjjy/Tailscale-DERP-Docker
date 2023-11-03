#!/usr/bin/env sh

#Start tailscaled and connect to tailnet
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state >> /dev/stdout &
/usr/bin/tailscale up --accept-routes=true --accept-dns=true --auth-key $TAILSCALE_AUTH_KEY >> /dev/stdout &

#Check for and or create certs directory
mkdir -p /root/derper/$TAILSCALE_DERP_HOSTNAME

#Start Tailscale derp server
/root/go/bin/derper --hostname $TAILSCALE_DERP_HOSTNAME --bootstrap-dns-names $TAILSCALE_DERP_HOSTNAME -certmode $TAILSCALE_DERP_CERTMODE -certdir /root/derper/$TAILSCALE_DERP_HOSTNAME --stun --verify-clients=$TAILSCALE_DERP_VERIFY_CLIENTS
