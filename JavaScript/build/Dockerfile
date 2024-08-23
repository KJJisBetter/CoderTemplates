FROM ubuntu

ARG USERNAME
ARG WORKSPACE_NAME
ARG USER_HOME=/home/${USERNAME}
ARG INSTALL_ZSH=false

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    sudo \
    vim \
    wget \
    build-essential \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Create user and set up sudo
RUN useradd --create-home --home-dir ${USER_HOME} --shell /bin/bash --groups sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Switch to the non-root user for the remaining operations
USER ${USERNAME}
WORKDIR ${USER_HOME}

# Install nvm and Node.js
ENV NVM_DIR ${USER_HOME}/.nvm
ENV NODE_VERSION 20
RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install -g yarn typescript nodemon

# Set up environment
ENV PATH ${USER_HOME}/.local/bin:${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}

# Add nvm to bashrc
RUN echo 'export NVM_DIR="${NVM_DIR}"' >> ${USER_HOME}/.bashrc \
    && echo '[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm' >> ${USER_HOME}/.bashrc \
    && echo '[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion' >> ${USER_HOME}/.bashrc \
    && echo 'export PATH=$HOME/.local/bin:$PATH' >> ${USER_HOME}/.bashrc

# Copy and run the custom Zsh setup script if INSTALL_ZSH is true
RUN if [ "$INSTALL_ZSH" = "true" ]; then \
        curl -o- https://raw.githubusercontent.com/KJJisBetter/personal-zsh-script/master/setup_zsh_env.sh | sudo bash && \
        sudo chsh -s $(which zsh) ${USERNAME} && \
        echo 'export NVM_DIR="${NVM_DIR}"' >> ${USER_HOME}/.zshrc && \
        echo '[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm' >> ${USER_HOME}/.zshrc && \
        echo '[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion' >> ${USER_HOME}/.zshrc && \
        echo 'export PATH=$HOME/.local/bin:$PATH' >> ${USER_HOME}/.zshrc; \
    fi