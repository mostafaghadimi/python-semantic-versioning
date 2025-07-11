FROM ghcr.io/astral-sh/uv:python3.13-alpine

LABEL maintainer="Mostafa Ghadimi <mostafa.ghadimi@yahoo.com>"
LABEL description="Automated semantic versioning using custom emoji commit parser"

RUN apk add --no-cache git bash

RUN mkdir -p /action
WORKDIR /action

COPY pyproject.toml uv.lock ./
COPY src/python-semantic-versioning/custom_commit_parser.py ./
COPY src/python-semantic-versioning/python-semantic-release-config.toml ./
COPY src/python-semantic-versioning/entrypoint.sh ./

RUN chmod +x entrypoint.sh && \
    uv sync --locked

ENV PYTHONPATH="/action"

ENTRYPOINT ["/action/entrypoint.sh"]
