FROM python:3.10.9-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

# install datalad
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        git git-annex parallel && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir datalad && \
    datalad wtf

# We must allow write permission to the /.cache directory
# for any user that runs the container
RUN mkdir -p /.cache && chmod +w /.cache

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]   