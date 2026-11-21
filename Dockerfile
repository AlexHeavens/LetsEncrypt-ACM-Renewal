FROM --platform=linux/amd64 certbot/dns-route53:v5.10.0

# EMAIL,DOMAIN,AWS_REGION,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN

COPY requirements.txt /
RUN pip install --no-cache-dir --requirement /requirements.txt

COPY run.sh /
CMD ["/run.sh"]
ENTRYPOINT [""]
