ARG PYTHON_VERSION=3
FROM python:${PYTHON_VERSION}-bookworm

ARG USER
ARG DEV_ENV=general
ARG WORKSPACE_NAME
ARG VENV_NAME=venv

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create the user
RUN useradd --groups sudo --no-create-home --shell /bin/bash ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

# Create the home directory structure
RUN mkdir -p /home/${USER}/${WORKSPACE_NAME}
WORKDIR /home/${USER}/${WORKSPACE_NAME}

# Set up a Python virtual environment in the workspace directory
RUN python -m venv /home/${USER}/${VENV_NAME}

# Upgrade pip
RUN /home/${USER}/${VENV_NAME}/bin/pip install --no-cache-dir --upgrade pip

# Install environment-specific packages
RUN if [ "$DEV_ENV" = "flask" ]; then \
        /home/${USER}/${VENV_NAME}/bin/pip install --no-cache-dir \
        flask \
        apifairy \
        flask-sqlalchemy \
        flask-migrate \
        gunicorn \
        pytest \
        pytest-cov \
        flask-login \
        flask-session \
        pydantic \
        flask-wtf \
        flask-mail; \
    elif [ "$DEV_ENV" = "django" ]; then \
        /home/${USER}/${VENV_NAME}/bin/pip install --no-cache-dir \
        django \
        djangorestframework \
        django-cors-headers \
        django-filter \
        django-extensions \
        django-storages \
        pytest-django \
        django-redis \
        django-debug-toolbar \
        django-environ \
        gunicorn \
        black \
        flake8; \
    elif [ "$DEV_ENV" = "data_science" ]; then \
        /home/${USER}/${VENV_NAME}/bin/pip install --no-cache-dir \
        numpy \
        pandas \
        matplotlib \
        seaborn \
        scipy \
        scikit-learn \
        tensorflow \
        keras \
        plotly \
        ggplot \
        jupyter; \
    elif [ "$DEV_ENV" = "machine_learning" ]; then \
        /home/${USER}/${VENV_NAME}/bin/pip install --no-cache-dir \
        numpy \
        pandas \
        matplotlib \
        scikit-learn \
        tensorflow \
        torch \
        scipy \
        seaborn \
        keras \
        nltk \
        jupyter; \
    fi

# Set ownership of the home directory to the user
RUN chown -R ${USER}:${USER} /home/${USER}

USER ${USER}

# Add virtual environment activation to bashrc
RUN echo "source /home/${USER}/${VENV_NAME}/bin/activate" >> /home/${USER}/.bashrc

# Install additional tools or set up environment based on DEV_ENV
RUN if [ "$DEV_ENV" = "general" ]; then \
        echo "echo 'General Python development environment activated'" >> /home/${USER}/.bashrc; \
    elif [ "$DEV_ENV" = "flask" ]; then \
        echo "echo 'Flask development environment activated'" >> /home/${USER}/.bashrc; \
    elif [ "$DEV_ENV" = "django" ]; then \
        echo "echo 'Django development environment activated'" >> /home/${USER}/.bashrc; \
    elif [ "$DEV_ENV" = "data_science" ]; then \
        echo "echo 'Data Science environment activated'" >> /home/${USER}/.bashrc; \
    elif [ "$DEV_ENV" = "machine_learning" ]; then \
        echo "echo 'Machine Learning environment activated'" >> /home/${USER}/.bashrc; \
    fi

# Set the working directory based on DEV_ENV
RUN if [ "$DEV_ENV" = "general" ]; then \
        echo "Setting workspace to /home/${USER}/${WORKSPACE_NAME}"; \
        mkdir -p /home/${USER}/${WORKSPACE_NAME}; \
    else \
        echo "Setting workspace to /home/${USER}/${WORKSPACE_NAME}/${VENV_NAME}"; \
        mkdir -p /home/${USER}/${WORKSPACE_NAME}/${VENV_NAME}; \
    fi

WORKDIR /home/${USER}/${WORKSPACE_NAME}