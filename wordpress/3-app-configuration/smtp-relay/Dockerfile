# Use an official Ubuntu as a base image
FROM ubuntu:24.04

# Set the environment to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Postfix and SASL for authentication
RUN apt-get update && \
    apt-get install -y \
        nullmailer \
        mailutils \
        socat && \
    rm -rf /var/lib/apt/lists/*

# Configure Postfix
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Postfix port 25 for SMTP
EXPOSE 25

# Start Postfix when the container starts
CMD ["/entrypoint.sh"]
