FROM ubuntu:22.04

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gnupg2 lsb-release software-properties-common vim curl python3-pip && \
apt-add-repository ppa:ansible/ansible && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ansible

RUN pip install boto3

RUN curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss && chmod +rx /usr/local/bin/goss

COPY goss.yaml /goss.yaml

CMD ["ansible"]
