FROM ghcr.io/astral-sh/uv:python3.13-alpine

LABEL maintainer="Mostafa Ghadimi <mostafa.ghadimi@yahoo.com>"
LABEL description="Automated semantic versioning using custom emoji commit parser"

RUN apk add --no-cache git bash

RUN mkdir -p /app

COPY pyproject.toml uv.lock /app/
COPY src/python-semantic-versioning/custom_commit_parser.py /app/
COPY src/python-semantic-versioning/python-semantic-release-config.toml /app/
COPY src/python-semantic-versioning/entrypoint.sh /app/

ENV PATH="/app/.venv/bin:/root/.local/bin:$PATH"
ENV PYTHONPATH=/app

RUN cd /app && \
    chmod +x entrypoint.sh && \
    uv sync

ENV PYTHONPATH="/app"

ENTRYPOINT ["/bin/bash", "-c", "/app/entrypoint.sh"]
