#!/usr/bin/env sh

set -o nounset
set -o errexit
set -o pipefail

certbot certonly \
  --agree-tos \
  --dns-route53 \
  --force-renewal \
  --email "${EMAIL}" \
  --domains "${DOMAIN}" 

aws acm import-certificate \
  --certificate file:///etc/letsencrypt/live/$DOMAIN/cert.pem \
  --private-key file:///etc/letsencrypt/live/$DOMAIN/privkey.pem \
  --certificate-chain file:///etc/letsencrypt/live/$DOMAIN/chain.pem
