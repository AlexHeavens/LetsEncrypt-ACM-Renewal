#!/bin/sh
# Run the real run.sh against fake certbot and aws commands, so no test reaches
# Let's Encrypt or an AWS account. The fakes on PATH are the only seam: each
# records its arguments and run.sh is otherwise unchanged.
# Usage: test/e2e.sh [path/to/run.sh]   (default: ../run.sh)
set -o nounset
set -o errexit

script=$(cd "$(dirname "$0")" && pwd)
run_sh="${1:-$script/../run.sh}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir "$work/bin"
cat > "$work/bin/certbot" <<'FAKE'
#!/bin/sh
echo "certbot $*" >> "$CALLS"
[ -z "${FAKE_CERTBOT_FAIL:-}" ]
FAKE
cat > "$work/bin/aws" <<'FAKE'
#!/bin/sh
echo "aws $*" >> "$CALLS"
FAKE
chmod +x "$work/bin/certbot" "$work/bin/aws"

failures=0
check() {
    if [ "$2" = "$3" ]; then
        echo "ok: $1"
    else
        echo "FAIL: $1"
        echo "  expected: $2"
        echo "  actual:   $3"
        failures=$((failures + 1))
    fi
}

# run_case <fail-certbot> [VAR=value ...]; sets status and calls
run_case() {
    fail_certbot=$1
    shift
    : > "$work/calls"
    status=0
    env -i PATH="$work/bin:/usr/bin:/bin" CALLS="$work/calls" FAKE_CERTBOT_FAIL="$fail_certbot" \
        "$@" sh "$run_sh" > "$work/out" 2>&1 || status=$?
    calls=$(cat "$work/calls")
}

run_case "" EMAIL=ops@example.com DOMAIN=example.com
check "success exits 0" 0 "$status"
check "success requests a DNS-validated certificate, then imports it" \
    "certbot certonly --agree-tos --dns-route53 --force-renewal --email ops@example.com --domains example.com
aws acm import-certificate --certificate file:///etc/letsencrypt/live/example.com/cert.pem --private-key file:///etc/letsencrypt/live/example.com/privkey.pem --certificate-chain file:///etc/letsencrypt/live/example.com/chain.pem" \
    "$calls"

run_case 1 EMAIL=ops@example.com DOMAIN=example.com
check "failed issuance exits non-zero" 1 "$([ "$status" -ne 0 ] && echo 1 || echo 0)"
check "failed issuance imports nothing into ACM" \
    "certbot certonly --agree-tos --dns-route53 --force-renewal --email ops@example.com --domains example.com" \
    "$calls"

run_case "" EMAIL=ops@example.com
check "missing DOMAIN exits non-zero" 1 "$([ "$status" -ne 0 ] && echo 1 || echo 0)"
check "missing DOMAIN calls nothing" "" "$calls"

run_case "" DOMAIN=example.com
check "missing EMAIL exits non-zero" 1 "$([ "$status" -ne 0 ] && echo 1 || echo 0)"
check "missing EMAIL calls nothing" "" "$calls"

[ "$failures" -eq 0 ] || { echo "$failures check(s) failed"; exit 1; }
echo "all checks passed"
