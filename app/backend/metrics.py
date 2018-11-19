from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter(
    "demo_app_request_count",
    "Request Count",
    ["app_name", "method", "endpoint", "http_status"]
)

REQUEST_LATENCY = Histogram(
    "demo_app_request_latency_seconds",
    "Request latency in seconds",
    ["app_name", "endpoint"]
)

VOTE_COUNT = Counter(
    "demo_app_vote_count",
    "Vote Count",
    ["app_name", "topic", "option"]
)
