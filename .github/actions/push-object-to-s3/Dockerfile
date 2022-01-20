FROM amazonlinux:2

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
ENV AWSCLI_PKG='https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'

RUN yum install -y unzip

RUN curl "${AWSCLI_PKG}" -o awscliv2.zip
RUN unzip -f awscliv2.zip && ./aws/install

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]