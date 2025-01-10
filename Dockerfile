FROM python:3.10.9-bullseye

ARG DEBIAN_FRONTEND="noninteractive"

ARG USERNAME=neurobagel_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# We create a new, non-root user to run datalad in the container
# we also create a new group with the same name as the user
# A user can overwrite the user name and group by running the 
# docker run command with the -u flag: https://docs.docker.com/reference/cli/docker/container/run/
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# install datalad
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        git git-annex parallel && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir datalad

COPY ./entrypoint.sh /entrypoint.sh

# Give all users permission to execute the entrypoint
RUN chmod +x /entrypoint.sh 

USER $USERNAME

# setup git
RUN git config --global --add user.name 'Ford Escort' && \
    git config --global --add user.email 42@H2G2.com && \
    datalad wtf

ENTRYPOINT ["/entrypoint.sh"]