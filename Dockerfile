FROM python:3.10.9-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

# install datalad
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        git git-annex parallel && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir datalad && \
    git config --global --add user.name 'Ford Escort' && \
    git config --global --add user.email 42@H2G2.com && \
    datalad wtf

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]