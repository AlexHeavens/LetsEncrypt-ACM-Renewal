# Let's Encrypt ACM Renewal

A Docker image that renews a Let's Encrypt TLS certificate for a domain managed by Route53 and imports it into Amazon Certificate Manager (ACM). Run it on a schedule to keep an ACM certificate current.

It is not a scheduler, and it does not attach the certificate to a load balancer or CDN. It always forces a renewal, so each run counts against Let's Encrypt's rate limits.

## Contents

- `run.sh`: requests the certificate with certbot (Route53 DNS validation), then imports it into ACM.
- `Dockerfile`, `requirements.txt`: the image, built on the pinned `certbot/dns-route53` release with a pinned AWS CLI.
- `test/e2e.sh`: runs `run.sh` against fake `certbot` and `aws` commands.
- `scripts/`: `install-gitleaks.sh` and `lint-workflows.sh`, the tools the hook and CI use.
- `pins/`: version pins for gitleaks and actionlint, bumped by Dependabot.

## Setup

Prerequisites: Docker, and an IAM user with write access to Route53 and ACM.

```
scripts/install-gitleaks.sh        # the pre-commit hook needs gitleaks
git config core.hooksPath .githooks
docker build --tag letsencrypt-acm-renewal:local .
```

Run it. This contacts Let's Encrypt and your AWS account.

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

## Tests

```
test/e2e.sh                                      # run.sh against fake certbot and aws
docker run --rm --entrypoint "" --volume "$PWD/test:/test:ro" \
    letsencrypt-acm-renewal:local sh /test/e2e.sh /run.sh   # same, inside the built image
shellcheck run.sh .githooks/pre-commit scripts/*.sh test/*.sh
scripts/lint-workflows.sh                        # actionlint
```

The tests never contact Let's Encrypt or AWS. Only the two commands are faked; the real `run.sh` and the real image run. Nothing here tests the real services: a real renewal is a manual check.
