FROM python:3

RUN apk --update add bash vim

COPY ./src /app

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install -r /app/requirements.txt
