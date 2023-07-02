# Let's Encrypt ACM Renewal
A tool for renewing TLS certificates for a domain managed by Route53, storing the results in Amazon Certificate Manager (ACM).

## Prerequisites
* Docker
* An IAM user with write access to Route53 and ACM

## Building
```
docker build --tag letsencrypt-acm-renewal:local .
```

## Usage
```
DOMAIN=your.domain.here
EMAIL=your@email.here

docker run \
        --env EMAIL \
        --env DOMAIN \
        --env AWS_ACCESS_KEY_ID \
        --env AWS_SECRET_ACCESS_KEY \
        --env AWS_SESSION_TOKEN \
        --env AWS_DEFAULT_REGION \
    --interactive --tty --rm \
    letsencrypt-acm-renewal:local
```