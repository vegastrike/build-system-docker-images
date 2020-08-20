ARG  from
FROM ${from}

WORKDIR /usr/src/build-system-docker-images

COPY script/ script/

RUN DEBIAN_FRONTEND=noninteractive script/bootstrap
