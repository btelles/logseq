# NOTE: please keep it in sync with .github pipelines
# NOTE: during testing make sure to change the branch below
# NOTE: before running the build-docker GH action edit
#       build-docker.yml and change the release channel from :latest to :testing

# Builder image
FROM clojure:temurin-8-tools-deps-1.12.6.1673-trixie-slim as builder

ARG DEBIAN_FRONTEND=noninteractive

# Install reqs
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    apt-transport-https \
    gpg \
    build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# install NodeJS & pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    corepack enable && corepack prepare pnpm@11.28.8 --activate

WORKDIR /data

# build Logseq static resources
RUN git clone -b master https://github.com/btelles/logseq.git .

RUN pnpm install --config.network-timeout=240000

RUN pnpm release

# Web App Runner image
FROM nginx:1.31-alpine3.24

COPY --from=builder /data/static /usr/share/nginx/html
