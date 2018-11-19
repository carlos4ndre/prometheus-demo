import time
from constants import APP_NAME
from flask import request
from metrics import REQUEST_COUNT, REQUEST_LATENCY


def start_timer():
    request.start_time = time.time()


def stop_timer(response):
    resp_time = time.time() - request.start_time
    REQUEST_LATENCY.labels(APP_NAME, request.path).observe(resp_time)
    return response


def record_request_data(response):
    REQUEST_COUNT.labels(APP_NAME, request.method, request.path, response.status_code).inc()
    return response


def setup_metrics(app):
    app.before_request(start_timer)
    app.after_request(record_request_data)
    app.after_request(stop_timer)
