from flask import Flask, render_template, request, jsonify, abort, redirect
app = Flask(__name__)

# app.run(debug=True)

# imports the "views.py"
from . import views
