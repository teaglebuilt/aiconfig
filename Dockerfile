FROM node:20

ARG CLAUDE_CODE_VERSION=latest

ENV FORCE_COLOR=1
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y --no-install-recommends \
  less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  make \
  jq \
  nano \
  vim \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share/npm-global

ARG USERNAME=node

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

USER node

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

CMD ["tail", "-f", "/dev/null"]
