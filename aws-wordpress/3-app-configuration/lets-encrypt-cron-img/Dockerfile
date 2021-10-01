FROM python:3-slim
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY ./src /app

ENTRYPOINT ["python3"]
CMD ["/app/main.py", "--cluster-config"]
