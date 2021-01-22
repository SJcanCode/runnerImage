# base
FROM ubuntu:18.04

# set the github runner version
ARG RUNNER_VERSION="2.276.1"

# set the runner config
ARG RUNNER_REPO="<your own repo user/repo name >"
ARG RUNNER_ACCESS_TOKEN="<your access token>"
ARG RUNNER_LABEL="self-hosted,Linux,X64"
ARG RUNNER_NAME="runner"

# set the password
ARG DOCKERUSER_PASSWORD="xxxxxx"

# update the base packages 
RUN apt-get update -y && apt-get upgrade -y

#install libs to for creating user with encrty password with openssl

RUN apt-get -y install apt-utils
RUN apt-get -y install sudo
RUN apt-get -y install openssl
RUN useradd -m -p $(echo "${DOCKERUSER_PASSWORD}" | openssl passwd -1 -stdin) docker


#add user to the sudor group
RUN usermod -aG sudo docker

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get install -y curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
#COPY start.sh start.sh

# make the script executable
#RUN chmod +x start.sh

#Change user to docker
USER docker

#config the runner
RUN cd /home/docker/actions-runner && ./config.sh --url https://github.com/${RUNNER_REPO} --token ${RUNNER_ACCESS_TOKEN} --name ${RUNNER_NAME} --labels ${RUNNER_LABEL}  --replace

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user


# set the entrypoint to the start.sh script
ENTRYPOINT ["./home/docker/actions-runner/run.sh"]
