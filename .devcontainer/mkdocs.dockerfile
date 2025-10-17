FROM python:3.11-slim

# Install prerequisites and Node.js (Node 18) via NodeSource on a Debian-based slim image
ARG DEBIAN_FRONTEND=noninteractive

# Install prerequisites, Node.js (Node 18) via NodeSource, and developer tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg dirmngr build-essential \
    git make wget bash-completion sudo && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install global node tooling helpful for hooks and release tooling (will be available in the dev image)
RUN npm install -g corepack && corepack enable || true

# Install dev toolchain from package.json (commitlint, husky, semantic-release, etc.)
# Copy package.json and optional package-lock.json from the build context and install
# Create a non-root user `dev` with UID 1000 and set up home
RUN useradd --create-home --shell /bin/bash --uid 1000 dev && \
    mkdir -p /home/dev/.local && chown -R dev:dev /home/dev

# Copy package.json and optional package-lock.json from the build context and install dev toolchain
COPY package.json package-lock.json* /tmp/
RUN set -eux; \
    npm config set audit false; \
    cd /tmp; \
    # Prefer deterministic install if lockfile exists, otherwise fall back to npm install
    if [ -f package-lock.json ]; then \
    npm ci --no-audit --no-fund --prefix /home/dev; \
    else \
    npm install --no-audit --no-fund --prefix /home/dev; \
    fi; \
    rm -rf /tmp/*; \
    chown -R dev:dev /home/dev

# Ensure project's node binaries are on PATH for the dev user
ENV PATH=/home/dev/node_modules/.bin:/home/dev/.local/bin/:${PATH}

# Ensure bash-completion is sourced for interactive shells for new users
RUN set -eux; \
    bash_completion_snippet='if [ -f /etc/bash_completion ]; then\n  . /etc/bash_completion\nelif [ -f /usr/share/bash-completion/bash_completion ]; then\n  . /usr/share/bash-completion/bash_completion\nfi'; \
    # Append snippet to /etc/skel/.bashrc so new users (including `dev`) get it
    mkdir -p /etc/skel && \
    { echo; echo "# Enable bash completion"; echo "$bash_completion_snippet"; } >> /etc/skel/.bashrc

# Set working directory to the dev user's home by default
WORKDIR /home/dev

# Copy project files and install Python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
RUN chown -R dev:dev /home/dev

# Set default user
USER dev

ENV HOME=/home/dev

WORKDIR /workspace


