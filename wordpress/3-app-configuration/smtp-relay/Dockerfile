# Use an official Ubuntu as a base image
FROM ubuntu:24.04

# Set the environment to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install Postfix and SASL for authentication
RUN apt-get update && \
    apt-get install -y postfix libsasl2-modules mailutils && \
    rm -rf /var/lib/apt/lists/*

# Fix Name service error for postfix
RUN echo 'nameserver 8.8.8.8' >> /var/spool/postfix/etc/resolv.conf

# Configure Postfix
COPY postfix.sh /postfix.sh
RUN chmod +x /postfix.sh

# Expose Postfix port 25 for SMTP
EXPOSE 25

# Start Postfix when the container starts
CMD ["/postfix.sh"]