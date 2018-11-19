import json
import redis
from constants import APP_NAME
from flask import Flask, Response, render_template, request
from middleware import setup_metrics
from metrics import VOTE_COUNT
from prometheus_client import generate_latest

app = Flask(__name__, static_folder="web/static", template_folder="web")
setup_metrics(app)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/vote/<topic>", methods=["GET", "POST"])
def vote(topic):
    if request.method == "POST":
        # parse data
        data = json.loads(request.data)
        option = data["option"]

        # increment data in redis
        conn = redis.Redis("redis")
        conn.incr(f"votes:{topic}:{option}")

        # increment prometheus stats
        VOTE_COUNT.labels(APP_NAME, topic, option).inc()

        # generate response
        response = json.dumps({"success": True})
    else:
        # get data in redis
        votes = {}
        conn = redis.Redis("redis", decode_responses=True)
        for key in conn.scan_iter(f"votes:{topic}:*"):
            option = key.split(":")[-1]
            value = int(conn.get(key))
            votes[option] = value

        # return dummy data for now
        response = json.dumps({"success": True, "votes": votes})
    return Response(response, mimetype="application/json")


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype="text/plain; charset=utf-8")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
