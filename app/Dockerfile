FROM alpine:3.6

# Install base dependencies
RUN apk add --update build-base

# Install python 3
RUN apk add --no-cache python3 python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    rm -r /root/.cache

# Install yarn
RUN apk add yarn

# Install npm
RUN apk add nodejs nodejs-npm

# Setup workdir
RUN mkdir /app
WORKDIR /app

# Setup flask
ADD backend /app
RUN pip install -r requirements.txt

# Build react app
ADD frontend /tmp/frontend
RUN cd /tmp/frontend && npm install && yarn run build

# Copy files over to flask project
RUN mkdir -p /app/web/static
RUN cp /tmp/frontend/build/index.html /app/web
RUN cp /tmp/frontend/build/manifest.json /app/web/static
RUN cp /tmp/frontend/build/favicon.ico /app/web/static
RUN cp -fr /tmp/frontend/build/static/* /app/web/static

# Clean up trash
RUN rm -fr /tmp/frontend

# Start server by default
ENTRYPOINT ["python3", "server.py"]
