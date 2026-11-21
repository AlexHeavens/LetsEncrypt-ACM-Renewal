# LetsEncrypt-ACM-Renewal

- Run: `docker build --tag letsencrypt-acm-renewal:local .`. A real run touches Let's Encrypt and AWS: never run it unasked.
- Test: `test/e2e.sh` (fake `certbot` and `aws` on PATH), then the same script inside the image (see README). Lint: `shellcheck run.sh .githooks/pre-commit scripts/*.sh test/*.sh` and `scripts/lint-workflows.sh`. No opt-in tests.
- Docs: `README.md` for setup.
- Before each commit, check the staged diff for secrets. The pre-commit hook needs `git config core.hooksPath .githooks`.
