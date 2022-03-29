from . import app
# import logging
# import json
# import os


@app.route("/")
def hello_world():
    return "Hello World from Flask"
