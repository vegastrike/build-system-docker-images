ARG CI_OS_IMAGE
ARG GIT_USER=vegastrike
ARG GIT_BRANCH=master

FROM vegastrike/vega-strike-build-env:${CI_OS_IMAGE}
ARG GIT_USER=vegastrike
ARG GIT_BRANCH=master

ENV GIT_USER=${GIT_USER}
ENV GIT_BRANCH=${GIT_BRANCH}

RUN mkdir -p /home/${GIT_USER}
WORKDIR /home/${GIT_USER}
RUN git clone https://github.com/${GIT_USER}/Vega-Strike-Engine-Source.git

WORKDIR /home/${GIT_USER}/Vega-Strike-Engine-Source
RUN git checkout ${GIT_BRANCH}
