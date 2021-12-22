FROM ubuntu

# Ensure docker build is using Bash instead of default /bin/sh
SHELL ["/bin/bash", "-c"]

WORKDIR /root

ENV TZ=Australia/Sydney

RUN apt-get update && apt-get install -y \
    iputils-ping \
    dnsutils \
    netcat \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["sleep"]
CMD ["infinity"]
