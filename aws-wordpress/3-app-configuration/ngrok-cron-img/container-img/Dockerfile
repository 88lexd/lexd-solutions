FROM python:3

COPY ./src /app

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install -r /app/requirements.txt
