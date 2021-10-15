FROM python:3

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt
ENV TZ=Australia/Sydney
COPY ./src /app

ENTRYPOINT ["python3"]
CMD ["/app/main.py"]
