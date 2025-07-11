FROM ghcr.io/astral-sh/uv:python3.13-alpine

LABEL maintainer="Mostafa Ghadimi <mostafa.ghadimi@yahoo.com>"
LABEL description="Automated semantic versioning using custom emoji commit parser"


RUN apk add --no-cache git bash

COPY pyproject.toml .
COPY uv.lock .
COPY src/python-semantic-versioning/custom_commit_parser.py .
COPY src/python-semantic-versioning/python-semantic-release-config.toml .
COPY src/python-semantic-versioning/entrypoint.sh .

RUN chmod +x entrypoint.sh && \
    uv sync --locked

ENTRYPOINT ["/bin/bash", "-c", "echo $PWD && ls -lah && echo $GITHUB_WORKSPACE"]
    # ENTRYPOINT ["entrypoint.sh"]
