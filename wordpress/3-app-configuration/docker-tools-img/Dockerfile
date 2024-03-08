FROM ubuntu

# Ensure docker build is using Bash instead of default /bin/sh
SHELL ["/bin/bash", "-c"]

WORKDIR /root

ENV TZ=Australia/Sydney

RUN apt-get update && apt-get install -y \
    iputils-ping \
    # TCP ping. (e.g. hping3 -S -p 80 google.com)
    hping3 \
    dnsutils \
    iproute2 \
    netcat \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["sleep"]
CMD ["infinity"]
