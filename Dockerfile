FROM --platform=linux/amd64 certbot/dns-route53:latest

# EMAIL,DOMAIN,AWS_REGION,AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_SESSION_TOKEN

RUN pip install awscli --upgrade

COPY run.sh /
CMD ["/run.sh"]
ENTRYPOINT [""]
