
#!/bin/bash

# COPY TO CRONTAB
#*/15 * * * * /home/ben/tasks/ddns.sh >/dev/null 2>&1

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Needs the DNS record pre-creating on Cloudflare
# Based on: https://gist.github.com/foobarhl/2480f956d26d49b035bf03ea1b01b40f
# Uses Cloudflare per site API Tokens (needs DNS:Edit for your domain zone)

# Cloudflare zone is the zone which holds the record
zone=
# dnsrecord is the A record which will be updated
dnsrecord=
# zoneid from domain overview page
zoneid=
# Cloudflare auth key
cloudflare_auth_key=

# Get the current external IP address
ip=$(curl -s -X GET https://checkip.amazonaws.com)

echo "Current IP is $ip"

if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
  echo "$dnsrecord is currently set to $ip; no changes needed"
  exit
fi

# get the dns record id
dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r  '{"result"}[] | .[0] | .id')

# update the record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
