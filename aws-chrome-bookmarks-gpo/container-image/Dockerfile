FROM tiangolo/uwsgi-nginx-flask:python3.8-alpine

RUN apk --update add bash vim

ENV STATIC_PATH /app/src/static

COPY ./app /app

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install -r /app/requirements.txt
