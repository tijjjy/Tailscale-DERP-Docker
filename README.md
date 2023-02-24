# Introduction

The aim of this repository is to create a simple and easy to use docker container with minimal setup to run your own Tailscale DERP server.  

There is two parts to the container, the tailscale client itself and the DERP server. The tailscale client is used to connect the container to your tailnet as it's own device, this allows the --verify-clients argument to be set on the derp server, this is so only devices in your own tailnet can use the DERP server, allowing it to the open internet in my opinion is a bad idea. 

Placing this DERP server at a closer geolocation than the default DERP servers to all of your devices can and will be beneficial for connections speeds between your devices that can't make a direct connection or at least struggle too.  

This is scalable, just build and run the container on servers in different countries if need be.  

My recommendation for the tailscale auth key to key an non-ephemeral key and once the device is connected disable the key expiry otherwise you will need to go back every now and then to renew it.

The container was built and tested on Ubuntu 22 5.19.0-28-generic. It's docker so it will most likely work on other distros as well.

# Prebuilt Container

If you don't want to build the container locally, you can change the image inside the docker-compose.yml file to use the following image.  
```
ghcr.io/tijjjy/tailscale-derp-docker:latest
```

# Instructions

Instructions can be followed below or you can find a more detailed walkthrough on my blog. [https://tijjjy.me/2023-01-22/Self-Host-Tailscale-Derp-Server](https://tijjjy.me/2023-01-22/Self-Host-Tailscale-Derp-Server)

### Ports Required

To allow full functionality of the DERP server, you will need to open/allow the following ports on your Firewall/Security Group

```
80:80/tcp
443:443/tcp
3478:3478/udp
```

Port 3478 is for STUN

### Changing the .env file variables

**IMPORTANT STEP**

Change the variables below, most importantly the hostname and tailscale auth key variable.  
Make sure the hostname is correct in your DNS zone or you will get an error when attempting to request a letsencrypt certificate

```
TAILSCALE_DERP_HOSTNAME=derp.example.com
TAILSCALE_DERP_VERIFY_CLIENTS=true
TAILSCALE_DERP_CERTMODE=letsencrypt
TAILSCALE_AUTH_KEY="ENTER YOUR TAILSCALE AUTH KEY HERE"
```

### Building Docker Image
```
docker build . -t tailscale-derp-docker:1.0
```
### Starting the image
```
docker compose up -d
```

### Checking containers logs

All processes and scripts are set to direct logs to stdout run the below command to monitor the container logs

```
docker logs -f tailscale-derp
```

# Changing the Tailscale ACL

Once your Tailscale DERP server is operational and you can see the new device in the devices section of the Tailscale admin console, You need to change your ACL to only allow the use of your DERP server and omit out the default Tailscale servers. This can be done by adding the following config at the bottom of your ACL file.

```
	"derpMap": {
		"OmitDefaultRegions": true,
		"Regions": {
			"900": {
				"RegionID":   900,
				"RegionCode": "myderpserver",
				"Nodes": [
					{
						"Name":     "1",
						"RegionID": 900,
						"HostName": "derp.example.com",
					},
				],
			},
		},
	},
```

More information can be found here [Tailscale DERP server docs](https://tailscale.com/kb/1118/custom-derp-servers/) on setting this config.  
