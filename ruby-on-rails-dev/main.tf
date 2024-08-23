terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "coder_provisioner" "me" {}
data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

provider "docker" {}

module "vault" {
  source     = "registry.coder.com/modules/hcp-vault-secrets/coder"
  version    = "1.0.7"
  agent_id   = coder_agent.main.id
  app_name   = "Coder"
  project_id = var.project_id
  secrets    = var.vault_secrets
}

variable "project_id" {
  type      = string
  description = "PROJECT ID"
}

variable "vault_secrets" {
  type        = list(string)
  description = "List of secret names to fetch from Vault"
}

output "vault_module" {
  value = module.vault
}

data "coder_parameter" "ruby_version" {
  name         = "ruby_version"
  display_name = "Ruby Version"
  description  = "Specify the Ruby version to install (e.g., 3.1.2, 2.7.6) or leave blank for latest"
  type         = "string"
  default      = ""
  validation {
    regex = "^$|^\\d+\\.\\d+\\.\\d+$"
    error = "Please enter a valid Ruby version in the format X.X.X (e.g., 3.1.2) or leave blank for latest"
  }
  mutable      = true
  icon         = "https://www.svgrepo.com/show/349494/ruby.svg"
}

data "coder_parameter" "rails_app" {
  name         = "rails_app"
  display_name = "Rails Application"
  description  = "Create a new Rails application or use an existing one"
  type         = "string"
  default      = "none"
  icon         = "https://www.svgrepo.com/show/349496/rubyonrails.svg"
  order        = 1
  mutable      = true
  option {
    name  = "Don't create a Rails application"
    value = "none"
  }
  option {
    name  = "Create a new Rails application named 'rails_app'"
    value = "rails_app"
  }
  option {
    name  = "Create a new Rails application with a custom name"
    value = "custom"
  }
}

data "coder_parameter" "custom_rails_app_name" {
  name         = "custom_rails_app_name"
  display_name = "Custom Rails Application Name"
  description  = "Enter a custom name for your Rails application"
  type         = "string"
  default      = ""
  icon         = "https://www.svgrepo.com/show/349496/rubyonrails.svg"
  order        = 2
  mutable      = true
}

data "coder_parameter" "database_choice" {
  name        = "database_choice"
  display_name = "Database"
  description = "Choose the database to install. ONLY DEFAULT AVAILABLE FOR NOW."
  type        = "string"
  default     = "none"
  mutable     = false
  icon        = "/icon/database.svg"
  order       = 3
  option {
    name  = "SQLite3 (Default, Recommended)"
    value = "none"
    icon  = "https://www.svgrepo.com/show/374094/sqlite.svg"
  }
  option {
    name  = "PostgreSQL"
    value = "postgresql"
    icon  = "https://www.svgrepo.com/show/439268/postgresql.svg"
  }
  # option {
  #   name  = "MySQL"
  #   value = "mysql"
  #   icon  = "https://www.svgrepo.com/show/439233/mysql.svg"
  # }
  # option {
  #   name  = "MongoDB"
  #   value = "mongodb"
  # }
}

data "coder_parameter" "install_custom_zsh_env" {
  name         = "install_custom_zsh_env"
  display_name = "Install custom Zsh environment"
  description  = "Install Zsh with Oh My Posh, Zinit, fzf, zoxide, eza, bat, and more. Sets up a productive shell with autocompletions, syntax highlighting, and git integrations."
  type         = "bool"
  default      = false
  mutable      = true
  icon         = "/icon/terminal.svg"
  order        = 4
}

data "coder_parameter" "nerd_font" {
  name         = "nerd_font"
  display_name = "Nerd Font"
  description  = "Select a Nerd Font to install (required if custom Zsh is enabled, optional otherwise)"
  type         = "string"
  default      = "None"
  mutable      = true
  order        = 5
  option {
    name  = "None"
    value = "None"
  }
  option {
    name  = "Fira Code"
    value = "FiraCode"
  }
  option {
    name  = "JetBrains Mono"
    value = "JetBrainsMono"
  }
  option {
    name  = "Hack"
    value = "Hack"
  }
  option {
    name  = "Source Code Pro"
    value = "SourceCodePro"
  }
  option {
    name  = "Ubuntu Mono"
    value = "UbuntuMono"
  }
  option {
    name  = "Custom"
    value = "custom"
  }
}

data "coder_parameter" "custom_nerd_font_path" {
  name         = "custom_nerd_font_path"
  display_name = "Custom Nerd Font Path"
  description  = "Enter the path to the .ttf file from the Nerd Fonts repository (required if Custom font is selected)"
  type         = "string"
  default      = ""  // Allow empty string as default
  mutable      = true
  order        = 6
}

data "coder_parameter" "install_ruby_extensions" {
  name         = "install_ruby_extensions"
  display_name = "Install Ruby Extensions"
  description  = "Install recommended VS Code extensions for Ruby and Rails development"
  type         = "bool"
  default      = false
  mutable      = true
  icon         = "https://www.svgrepo.com/show/349494/ruby.svg"
  order        = 7
}

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    log_message() {
      echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/workspace_setup.log
    }

    log_message "Starting workspace setup..."

    # Create workspace directory
    WORKSPACE_DIR="/home/${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}"
    mkdir -p "$WORKSPACE_DIR"
    log_message "Created workspace directory: $WORKSPACE_DIR"

    # Install the latest code-server
    log_message "Installing latest version of code-server"
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone

    # Start code-server
    log_message "Starting code-server"
    /home/${data.coder_workspace_owner.me.name}/.local/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &

    # Wait for code-server to start (with timeout)
    log_message "Waiting for code-server to start..."
    timeout 30s bash -c 'until pgrep -f code-server > /dev/null; do sleep 1; done'
    if [ $? -eq 0 ]; then
      log_message "code-server is running."
    else
      log_message "Timeout waiting for code-server to start."
      exit 1
    fi

    # Signal that the main script is done
    log_message "Main workspace setup completed!"
    touch /tmp/main_script_done
  EOT

  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.coder_workspace_owner.me.email}"
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

resource "coder_script" "install_ruby_extensions" {
  agent_id     = coder_agent.main.id
  display_name = "Install Ruby Extensions and Configure VS Code"
  run_on_start = true
  depends_on   = [coder_agent.main, coder_script.rails_setup]
  icon         = "/icon/vscode.svg"
  script = <<EOT
#!/bin/bash
set -euo pipefail

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/vscode_setup.log
}

log_message "Starting VS Code setup and Ruby extensions installation..."

# Wait for main setup to finish
log_message "Waiting for main setup to complete..."
timeout 300s bash -c 'until [ -f /tmp/main_script_done ]; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for main setup. Exiting."
  exit 1
fi

# Wait for Rails setup to finish
log_message "Waiting for Rails setup to complete..."
timeout 600s bash -c 'until [ -f /tmp/rails_setup_done ]; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for Rails setup. Exiting."
  exit 1
fi
log_message "Rails setup completed. Proceeding with VS Code setup."

# Ensure code-server is in the PATH and running
export PATH="$HOME/.local/bin:$PATH"

log_message "Waiting for code-server to be ready..."
timeout 60s bash -c 'until pgrep -f code-server > /dev/null; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for code-server to start. Exiting."
  exit 1
fi
sleep 10  # Give code-server a moment to fully initialize

# Function to install extensions
install_extensions() {
  if [ "${data.coder_parameter.install_ruby_extensions.value}" = "true" ]; then
    log_message "Installing Ruby extensions..."
    local extensions=(
      "rebornix.Ruby"
      "mbessey.vscode-rufo"
      "aliariff.vscode-erb-beautify"
      "vortizhe.simple-ruby-erb"
      "Shopify.ruby-lsp"
      "sorbet.sorbet-vscode-extension"
    )
    
    for ext in "$${extensions[@]}"; do
      log_message "Installing extension: $ext"
      if ! code-server --install-extension "$ext" --force; then
        log_message "Failed to install $ext, continuing with next extension"
      fi
    done
    log_message "Extension installation process completed"
  else
    log_message "Skipping Ruby extensions installation as it was not requested."
  fi
}

# Install extensions
install_extensions

# Apply VS Code settings
log_message "Applying VS Code settings..."
SETTINGS_FILE="$HOME/.local/share/code-server/User/settings.json"

# Determine font settings
FONT_SETTINGS='"editor.fontFamily": "monospace",'
if [ -f "/tmp/font_name" ]; then
  FONT_NAME=$(cat /tmp/font_name)
  FONT_SETTINGS='"editor.fontFamily": "'"$FONT_NAME"' Nerd Font, monospace",'
fi

# Create or update settings file
cat > "$SETTINGS_FILE" <<EOF
{
  "workbench.colorTheme": "Default Dark+",
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 14,
  $FONT_SETTINGS
  "editor.tabSize": 2,
  "editor.rulers": [80, 120],
  "files.trimTrailingWhitespace": true,
  "ruby.useLanguageServer": true,
  "ruby.lint": {
    "rubocop": true
  },
  "ruby.format": "rubocop",
  "[ruby]": {
    "editor.formatOnSave": true
  },
  "files.associations": {
    "*.erb": "erb"
  },
  "[erb]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "aliariff.vscode-erb-beautify"
  },
  "emmet.includeLanguages": {
    "erb": "html"
  },
  "beautify.language": {
    "html": ["htm", "html", "erb"]
  }
}
EOF

log_message "VS Code settings applied successfully."
log_message "VS Code setup and Ruby extensions installation completed."
touch /tmp/vscode_setup_done
EOT
}

resource "coder_script" "rails_setup" {
  agent_id     = coder_agent.main.id
  display_name = "Rails Setup"
  depends_on   = [coder_agent.main, coder_script.postgres_setup]
  run_on_start = true
  icon         = "https://www.svgrepo.com/show/349496/rubyonrails.svg"
  script = <<EOT
#!/bin/bash
set -euo pipefail

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/rails_setup.log
}

log_message "Starting Rails setup..."

# Wait for PostgreSQL setup to finish if it's needed
if [ "${data.coder_parameter.database_choice.value}" = "postgresql" ]; then
  log_message "Waiting for PostgreSQL setup to complete..."
  timeout 300s bash -c 'until [ -f /tmp/postgres_setup_done ]; do sleep 2; done'
  if [ $? -ne 0 ]; then
    log_message "Timeout waiting for PostgreSQL setup. Exiting."
    exit 1
  fi
  log_message "PostgreSQL setup completed. Proceeding with Rails setup."
  
  # Source database details
  source /tmp/db_details
fi

WORKSPACE_DIR="/home/${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}"
DB_CHOICE="${data.coder_parameter.database_choice.value}"
CUSTOM_ZSH="${data.coder_parameter.install_custom_zsh_env.value}"

# Wait for PostgreSQL setup to finish if it's needed
if [ "$DB_CHOICE" = "postgresql" ]; then
  echo "Waiting for PostgreSQL setup to complete..."
  while [ ! -f /tmp/postgres_setup_done ]; do
    sleep 2
  done
  echo "PostgreSQL setup completed. Proceeding with Rails setup."
  
  # Source database details
  source /tmp/db_details
fi

# Function to export variables to shell configuration files
export_db_vars() {
  local shell_rc="$1"
  if [ "$DB_CHOICE" = "postgresql" ]; then
    echo "export DB_NAME='$DB_NAME'" >> "$shell_rc"
    echo "export DB_HOST='$DB_HOST'" >> "$shell_rc"
    echo "export DB_PORT='$DB_PORT'" >> "$shell_rc"
    echo "export DB_USERNAME='$DB_USER'" >> "$shell_rc"
    echo "export DB_PASSWORD='$(grep $DB_NAME ~/.pgpass | cut -d: -f5)'" >> "$shell_rc"
  fi
}

# Create Rails application if requested
if [ "${data.coder_parameter.rails_app.value}" != "none" ]; then
  APP_NAME="${data.coder_parameter.rails_app.value == "custom" ? data.coder_parameter.custom_rails_app_name.value : "rails_app"}"
  if [ ! -d "$WORKSPACE_DIR/$APP_NAME" ]; then
    log_message "Creating new Rails application: $APP_NAME"
    cd $WORKSPACE_DIR
    
    # Create Rails app with specified database
    case $DB_CHOICE in
      postgresql)
        rails new $APP_NAME -d postgresql
        ;;
      *)
        rails new $APP_NAME
        ;;
    esac

    cd $APP_NAME
    bundle install

    # Configure database.yml for the chosen database
    if [ "$DB_CHOICE" = "postgresql" ]; then
      # Update database.yml securely
      cat > config/database.yml << EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: <%= ENV['DB_NAME'] %>
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV['DB_PORT'] %>
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>

test:
  <<: *default
  database: <%= ENV['DB_NAME'] %>_test

production:
  <<: *default
  database: <%= ENV['DB_NAME'] %>_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
EOF

      log_message "Updated database.yml with secure PostgreSQL configuration"

      # Export variables to .bashrc
      export_db_vars ~/.bashrc

      # If custom Zsh is selected, also export to .zshrc
      if [ "$CUSTOM_ZSH" = "true" ]; then
        export_db_vars ~/.zshrc
      fi

      # Source the appropriate RC file
      if [ "$CUSTOM_ZSH" = "true" ]; then
        source ~/.zshrc
      else
        source ~/.bashrc
      fi
      
      log_message "Database environment variables set and sourced."

    elif [ "$DB_CHOICE" = "sqlite3" ]; then
      log_message "Using default SQLite3 configuration"
    fi

    # Run database setup with error handling
    if [ "$DB_CHOICE" = "postgresql" ]; then
      if rails db:create; then
        log_message "Database created successfully"
        rails db:migrate
      else
        log_message "Failed to create database. Check the error message above."
        exit 1
      fi
    else
      log_message "Using default database setup"
      rails db:create
      rails db:migrate
    fi

    log_message "Rails application $APP_NAME created successfully with $DB_CHOICE database."

    # Set up .gitignore to exclude sensitive files
    echo "# Ignore sensitive configuration files" >> .gitignore
    echo ".env" >> .gitignore
    echo "config/master.key" >> .gitignore
    echo "config/credentials.yml.enc" >> .gitignore
    log_message "Updated .gitignore to exclude sensitive files"

  else
    log_message "Rails application $APP_NAME already exists."
    cd $WORKSPACE_DIR/$APP_NAME
    
    # Ensure all gems are installed
    log_message "Ensuring all gems are installed..."
    bundle install

    # Ensure database is set up correctly even for existing applications
    log_message "Checking database setup for existing application..."
    if rails db:version > /dev/null 2>&1; then
      log_message "Database is set up correctly."
    else
      log_message "Database not set up. Attempting to create and migrate..."
      rails db:create
      rails db:migrate
    fi
  fi
else
  log_message "No Rails application requested. Using default workspace."
fi

log_message "Rails setup completed."
touch /tmp/rails_setup_done
EOT

}

resource "coder_script" "postgres_setup" {
  agent_id     = coder_agent.main.id
  display_name = "PostgreSQL Setup"
  run_on_start = true
  icon         = "/icon/database.svg"
  script = <<EOT
#!/bin/bash
set -euo pipefail

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/postgres_setup.log
}

# Check if PostgreSQL is selected as the database
if [ "${data.coder_parameter.database_choice.value}" != "postgresql" ]; then
  log_message "PostgreSQL setup not required. Exiting."
  touch /tmp/postgres_setup_done
  exit 0
fi

log_message "Waiting for main script to complete..."
timeout 300s bash -c 'until [ -f /tmp/main_script_done ]; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for main script. Exiting."
  exit 1
fi
log_message "Main script completed. Starting PostgreSQL setup."

# Use the secrets from environment variables
DB_IP="$${postgresql_ip}"
ADMIN_PASSWORD="$${admin_password}"

# Set up variables
CODER_USER="${data.coder_workspace_owner.me.name}"
WORKSPACE_ID="${data.coder_workspace.me.id}"
PGPASS_FILE=~/.pgpass

# Ensure .pgpass file exists
touch "$${PGPASS_FILE}"
chmod 0600 "$${PGPASS_FILE}"

# Function to generate a unique, short identifier for the workspace
generate_workspace_id() {
  echo "$${WORKSPACE_ID}" | md5sum | cut -c1-8
}

# Function to execute SQL safely using admin credentials
execute_sql() {
  PGPASSWORD="$${ADMIN_PASSWORD}" psql -h "$${DB_IP}" -U postgres -c "$1"
}

# Function to add or update a line in .pgpass file
update_pgpass() {
  local host="$1"
  local port="$2"
  local database="$3"
  local user="$4"
  local password="$5"

  # Remove any existing line for this combination
  sed -i "\|^$${host}:$${port}:$${database}:$${user}:|d" "$${PGPASS_FILE}"
  
  # Append the new line
  echo "$${host}:$${port}:$${database}:$${user}:$${password}" >> "$${PGPASS_FILE}"
  
  # Ensure correct permissions
  chmod 0600 "$${PGPASS_FILE}"
}

# Function to check if a database exists
database_exists() {
  local db_name="$1"
  execute_sql "SELECT 1 FROM pg_database WHERE datname='$db_name'" | grep -q 1
}

# Function to check if a user exists
user_exists() {
  local username="$1"
  execute_sql "SELECT 1 FROM pg_roles WHERE rolname='$username'" | grep -q 1
}

# Function to create or reuse credentials
setup_credentials() {
  WORKSPACE_SHORT_ID=$(generate_workspace_id)
  DB_PREFIX="coder"
  
  DB_NAME="$${DB_PREFIX}_$${CODER_USER}_$${WORKSPACE_SHORT_ID}"
  
  # Check if the database already exists
  if database_exists "$DB_NAME"; then
    log_message "Database $DB_NAME already exists. Reusing it."
    # Try to find existing user in .pgpass
    EXISTING_CREDS=$(grep "$DB_NAME" "$PGPASS_FILE" | tail -n 1)
    if [ -n "$EXISTING_CREDS" ]; then
      DB_USER=$(echo $EXISTING_CREDS | cut -d: -f4)
      DB_PASSWORD=$(echo $EXISTING_CREDS | cut -d: -f5)
      log_message "Reusing existing credentials for $DB_NAME"
    else
      # If no existing user found, create a new one
      TIMESTAMP=$(date +%Y%m%d%H%M%S)
      DB_USER="user_$${CODER_USER}_$${TIMESTAMP}"
      DB_PASSWORD=$(openssl rand -base64 12)
      log_message "Creating new user $DB_USER for existing database $DB_NAME"
      execute_sql "CREATE USER \"$${DB_USER}\" WITH PASSWORD '$${DB_PASSWORD}';"
      execute_sql "GRANT ALL PRIVILEGES ON DATABASE \"$${DB_NAME}\" TO \"$${DB_USER}\";"
    fi
  else
    # Create new database and user
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    DB_USER="user_$${CODER_USER}_$${TIMESTAMP}"
    DB_PASSWORD=$(openssl rand -base64 12)

    log_message "Creating new database user $${DB_USER}..."
    execute_sql "CREATE USER \"$${DB_USER}\" WITH PASSWORD '$${DB_PASSWORD}';"

    log_message "Creating database $${DB_NAME}..."
    execute_sql "CREATE DATABASE \"$${DB_NAME}\" OWNER \"$${DB_USER}\";"

    log_message "Granting privileges on $${DB_NAME} to $${DB_USER}..."
    execute_sql "GRANT ALL PRIVILEGES ON DATABASE \"$${DB_NAME}\" TO \"$${DB_USER}\";"
  fi

  # Update .pgpass with credentials (only for the application database)
  update_pgpass "$${DB_IP}" "5432" "$${DB_NAME}" "$${DB_USER}" "$${DB_PASSWORD}"

  log_message "Credentials added/updated in $${PGPASS_FILE}"

  # Export database details for Rails setup
  echo "DB_NAME=$${DB_NAME}" > /tmp/db_details
  echo "DB_USER=$${DB_USER}" >> /tmp/db_details
  echo "DB_HOST=$${DB_IP}" >> /tmp/db_details
  echo "DB_PORT=5432" >> /tmp/db_details
  echo "DB_PASSWORD=$${DB_PASSWORD}" >> /tmp/db_details
}

# Main execution
setup_credentials

# Clean up any existing 'postgres' database entry
sed -i "/^.*:5432:postgres:/d" "$PGPASS_FILE"

log_message "PostgreSQL setup completed successfully."
log_message "Connection details stored in $${PGPASS_FILE}"

# Display connection details (excluding password)
log_message "Connection Details:"
log_message "Database: $${DB_NAME}"
log_message "User: $${DB_USER}"
log_message "Password: [Stored securely in $${PGPASS_FILE}]"

# Main execution
setup_credentials

log_message "PostgreSQL setup completed successfully."
touch /tmp/postgres_setup_done
EOT

  depends_on = [coder_agent.main, module.vault]
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/${data.coder_workspace_owner.me.name}/${data.coder_workspace.me.name}${data.coder_parameter.rails_app.value != "none" ? "/${data.coder_parameter.rails_app.value == "custom" ? data.coder_parameter.custom_rails_app_name.value : "rails_app"}" : ""}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
  depends_on = [coder_script.rails_setup]
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"
  # Protect the volume from being deleted due to changes in attributes.
  lifecycle {
    ignore_changes = all
  }
  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}


resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}"
  build {
    context    = "./build"
    dockerfile = "Dockerfile"
    build_args = {
      USERNAME                = data.coder_workspace_owner.me.name
      RUBY_VERSION            = data.coder_parameter.ruby_version.value != "" ? data.coder_parameter.ruby_version.value : null
      DATABASE_CHOICE         = data.coder_parameter.database_choice.value
      INSTALL_ZSH             = data.coder_parameter.install_custom_zsh_env.value
      INSTALL_RUBY_EXTENSIONS = data.coder_parameter.install_ruby_extensions.value
    }
  }
  triggers = {
    dir_sha1   = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
    dockerfile = filesha1("./build/Dockerfile")
    settings   = filesha1("./build/settings.json")
  }
}

resource "docker_container" "workspace" {
  count    = data.coder_workspace.me.start_count
  image    = docker_image.main.name
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name
  command  = ["sh", "-c", coder_agent.main.init_script]
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "HOME=/home/${data.coder_workspace_owner.me.name}"
  ]
  # Add these lines to give the container the necessary privileges
  privileged = true
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/${data.coder_workspace_owner.me.name}"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }
  # Add this line to use the custom network
  networks_advanced {
    name = docker_network.workspace_network.name
  }
  capabilities {
    add = ["SYS_ADMIN"]
  }
  # Ensure the container runs as the correct user
  user = data.coder_workspace_owner.me.name

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}

# Create a new docker_network resource
resource "docker_network" "workspace_network" {
  name = "network-${data.coder_workspace.me.id}"
  driver = "bridge"

  labels {
    label = "coder.owner"
    value = data.coder_workspace_owner.me.name
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace_owner.me.id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}

