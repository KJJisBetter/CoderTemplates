ARG RUBY_VERSION=3
FROM ruby:${RUBY_VERSION}-bookworm

ARG USERNAME=coder
ARG USER_HOME=/home/${USERNAME}
ARG DATABASE_CHOICE
ARG INSTALL_ZSH=false
ARG INSTALL_RUBY_EXTENSIONS=false

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nano \
    curl \
    git \
    sudo \
    vim \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libreadline-dev \
    libffi-dev \
    libgdbm-dev \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Create user and set up sudo
RUN useradd --create-home --home-dir ${USER_HOME} --shell /bin/bash --groups sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to the non-root user for the remaining operations
USER ${USERNAME}
WORKDIR ${USER_HOME}

# Install chosen database
RUN if [ "$DATABASE_CHOICE" = "postgresql" ]; then \
        sudo apt-get update && sudo apt-get install -y postgresql-client libpq-dev; \
    elif [ "$DATABASE_CHOICE" = "mysql" ]; then \
        sudo apt-get update && sudo apt-get install -y default-mysql-client default-libmysqlclient-dev; \
    elif [ "$DATABASE_CHOICE" = "mongodb" ]; then \
        sudo apt-get update && sudo apt-get install -y gnupg && \
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add - && \
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
        sudo apt-get update && sudo apt-get install -y mongodb-org-shell mongodb-mongosh; \
    fi

# Install Rails and other gems
RUN gem install rails bundler rubocop rufo htmlbeautifier

# Conditionally install Zsh setup
RUN if [ "$INSTALL_ZSH" = "true" ]; then \
        curl -o- https://raw.githubusercontent.com/KJJisBetter/personal-zsh-script/master/setup_zsh_env.sh | sudo bash && \
        sudo chsh -s $(which zsh) ${USERNAME}; \
    fi

# Add code-server to shell profile
RUN echo 'export PATH=$HOME/.local/bin:$PATH' >> ${USER_HOME}/.profile

# Set up shell configuration
RUN if [ "$INSTALL_ZSH" = "true" ]; then \
        echo 'export PATH=$HOME/.local/bin:$PATH' >> ${USER_HOME}/.zshrc; \
    else \
        echo 'export PATH=$HOME/.local/bin:$PATH' >> ${USER_HOME}/.bashrc; \
    fi