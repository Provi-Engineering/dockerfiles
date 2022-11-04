FROM ubuntu:22.04

RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get -y install -y --no-install-recommends gnupg2 lsb-release software-properties-common vim curl && \
apt-add-repository ppa:ansible/ansible && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ansible python3-pip

RUN pip install boto3

RUN curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss && chmod +rx /usr/local/bin/goss

COPY goss.yaml /goss.yaml

CMD ["/usr/local/bin/goss", "validate"]
