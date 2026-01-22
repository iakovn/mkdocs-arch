FROM python:3.12-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install prerequisites, Node.js (Node 22) via NodeSource, and developer tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg dirmngr build-essential \
    git make wget bash-completion sudo && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Ensure bash-completion is sourced for interactive shells for new users
RUN set -eux; \
    bash_completion_snippet='if [ -f /etc/bash_completion ]; then\n  . /etc/bash_completion\nelif [ -f /usr/share/bash-completion/bash_completion ]; then\n  . /usr/share/bash-completion/bash_completion\nfi'; \
    # Append snippet to /etc/skel/.bashrc so new users (including `dev`) get it
    mkdir -p /etc/skel && \
    { echo; echo "# Enable bash completion"; echo "$bash_completion_snippet"; } >> /etc/skel/.bashrc

# Install dev toolchain from package.json (commitlint, husky, semantic-release, etc.)
# Copy package.json and optional package-lock.json from the build context and install
# Create a non-root user `dev` with UID 1000 and set up home
RUN useradd --create-home --shell /bin/bash --uid 1000 dev && \
    mkdir -p /home/dev/.local && chown -R dev:dev /home/dev

# Ensure project's binaries are on PATH for the dev user
ENV PATH=/home/dev/node_modules/.bin:/home/dev/.local/bin/:${PATH}

# Set default user and working dir
ENV HOME=/home/dev
USER dev
WORKDIR /home/dev


# Copy project files and install Python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --user --no-cache-dir -r /tmp/requirements.txt

# Copy package.json and optional package-lock.json from the build context and install dev toolchain
COPY --chown=dev:dev package.json package-lock.json /home/dev/

# configure npm
RUN set -eux; \
    npm config set audit false; \
    npm config set prefix /home/dev;

# configre git to consider /workspace a safe directory (for devcontainer/mkdocs in CI)
RUN git config --global --add safe.directory /workspace

WORKDIR /workspace