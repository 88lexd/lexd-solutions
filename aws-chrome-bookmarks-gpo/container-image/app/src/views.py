from . import app
import debugpy
# import logging
# import json
# import os


@app.route("/")
def hello_world():
    a = "alex"
    debugpy.listen(5678)
    print("Waiting for debugger attach")
    debugpy.wait_for_client()
    debugpy.breakpoint()
    return "Hello World from Flask"
