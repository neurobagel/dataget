FROM python:3.10.9-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

ARG USERNAME=neurobagel_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

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

# Change ownership of the entrypoint script
RUN chown $USERNAME:$USERNAME /entrypoint.sh
USER $USERNAME

# setup git
RUN git config --global user.email "user@neurobagel.org" && \
    git config --global user.name "Neurobagel User"

ENTRYPOINT ["/entrypoint.sh"]