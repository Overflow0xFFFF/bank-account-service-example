#/////////////////////////////////////////////////////////////////////////////#
#
# Copyright (c) 2022, Joshua Ford
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#/////////////////////////////////////////////////////////////////////////////#

FROM debian:11-slim AS builder
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes \
      python3-venv gcc libpython3-dev libpq-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip setuptools wheel pdm

#//////////////////////////////////////////////////////////////////////////////

FROM builder AS builder-app
RUN mkdir /pdm
COPY . /app
WORKDIR /app
RUN /venv/bin/pdm install && \
    /venv/bin/pdm sync

#//////////////////////////////////////////////////////////////////////////////

# Unfortunately, due to the way Distroless works, we need Postgres libraries
# installed into the container. Importing them from another container is
# not sufficient, so I've opted to use Debian Slim as the base instead.
#FROM gcr.io/distroless/python3-debian11
FROM debian:11-slim
LABEL maintainer="joshua.ford@protonmail.com"

# Container metadata
ARG BUILD_DATE
ARG GIT_REF

LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.revision=$GIT_REF

COPY --from=builder-app /venv /venv
COPY --from=builder-app /app /app

RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes \
      python3 python3-venv libpq5 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000

ENV FLASK_APP=app/app.py

WORKDIR /app
USER 1000
ENTRYPOINT ["/app/docker-entrypoint.sh"]

