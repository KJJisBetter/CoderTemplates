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

data "coder_parameter" "install_extensions" {
  name         = "install_extensions"
  display_name = "Install VS Code Extensions"
  description  = "Whether to install a set of common JavaScript/React extensions"
  type         = "bool"
  default      = false
  mutable      = true
  order        = 3
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
  description  = "Enter the path to the .ttf file from the Nerd Fonts repository (required if Custom font is selected) Ex. (patched-fonts/FiraCode/Medium/FiraCodeNerdFont-Medium.ttf)"
  type         = "string"
  default      = ""  // Allow empty string as default
  mutable      = true
  order        = 6
}


data "coder_provisioner" "me" {
}

provider "docker" {
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

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
    curl -fsSL https://code-server.dev/install.sh | sh

    # Start code-server
    log_message "Starting code-server"
    code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &

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
    key          = "cpu"
    script       = "coder stat cpu"
    interval     = 1
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage"
    key          = "mem"
    script       = "coder stat mem"
    interval     = 1
    timeout      = 1
  }

  metadata {
    display_name = "Disk Usage"
    key          = "disk"
    script       = "coder stat disk"
    interval     = 60
    timeout      = 1
  }
}

resource "coder_script" "vscode_setup" {
  agent_id     = coder_agent.main.id
  display_name = "Install VS Code Extensions, Fonts, and Configure Settings"
  run_on_start = true
  icon         = "/icon/vscode.svg"
  script = <<EOT
#!/bin/bash
set -euo pipefail

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/vscode_setup.log
}

log_message "Starting VS Code setup, font installation, and extension installation..."

# Wait for main setup to finish
log_message "Waiting for main setup to complete..."
timeout 300s bash -c 'until [ -f /tmp/main_script_done ]; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for main setup. Exiting."
  exit 1
fi

# Wait for code-server to be fully ready
log_message "Waiting for code-server to be fully ready..."
for i in {1..30}; do
  if curl -s http://localhost:13337/healthz > /dev/null; then
    log_message "code-server is fully ready."
    break
  fi
  if [ $i -eq 30 ]; then
    log_message "Timeout waiting for code-server to be fully ready."
    exit 1
  fi
  sleep 1
done

# Font Installation
SELECTED_FONT="${data.coder_parameter.nerd_font.value}"
INSTALL_FONT=false

if [ "${data.coder_parameter.install_custom_zsh_env.value}" = "true" ]; then
  log_message "Zsh is selected. Setting it as the default shell..."
  sudo chsh -s $(which zsh) ${data.coder_workspace_owner.me.name}
  log_message "Zsh has been set as the default shell."
  INSTALL_FONT=true
  # If no font was selected, default to FiraCode for Zsh
  if [ "$SELECTED_FONT" = "None" ]; then
    log_message "No nerd font selected for custom zsh environment. Setting default nerd font (FiraCode)"
    SELECTED_FONT="FiraCode"
  fi
else
  log_message "Using Bash as the default shell..."
  # Only install font if explicitly selected
  if [ "$SELECTED_FONT" != "None" ]; then
    INSTALL_FONT=true
  fi
fi

# Install selected Nerd Font if required
if [ "$INSTALL_FONT" = true ]; then
  if [ "$SELECTED_FONT" = "custom" ]; then
    FONT_PATH="${data.coder_parameter.custom_nerd_font_path.value}"
    # Validate custom font path
    if [[ ! "$FONT_PATH" =~ ^patched-fonts/.+\.ttf$ ]]; then
      log_message "Error: Invalid custom font path. It should start with 'patched-fonts/' and end with '.ttf'"
      exit 1
    fi
  else
    case "$SELECTED_FONT" in
      "FiraCode")
        FONT_PATH="patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf"
        ;;
      "JetBrainsMono")
        FONT_PATH="patched-fonts/JetBrainsMono/Ligatures/Medium/JetBrainsMonoNerdFontMono-Medium.ttf"
        ;;
      "Hack")
        FONT_PATH="patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"
        ;;
      "SourceCodePro")
        FONT_PATH="patched-fonts/SourceCodePro/Medium/SauceCodeProNerdFontMono-Medium.ttf"
        ;;
      "UbuntuMono")
        FONT_PATH="patched-fonts/UbuntuMono/Regular/UbuntuMonoNerdFont-Regular.ttf"
        ;;
      *)
        log_message "Unknown font selected. Using FiraCode as default."
        FONT_PATH="patched-fonts/FiraCode/Medium/FiraCodeNerdFontMono-Medium.ttf"
        ;;
    esac
  fi
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/$FONT_PATH"
  FONT_FILE=$(basename "$FONT_PATH")
  log_message "Installing Nerd Font: $FONT_FILE"
  mkdir -p ~/.local/share/fonts
  curl -fLo ~/.local/share/fonts/"$FONT_FILE" "$FONT_URL"
  fc-cache -f -v

  # Extract font name without "NerdFont" suffix and format it properly
  FONT_NAME=$(echo "$FONT_FILE" | sed -E 's/(.*)NerdFont.*\.ttf/\1/' | sed 's/\([A-Z]\)/ \1/g' | sed 's/^ //' | sed 's/  / /g')
  echo "FONT_NAME=$FONT_NAME" > /tmp/font_name
  log_message "Extracted font name: $FONT_NAME"
else
  log_message "No font installation required."
fi

# Install extensions if requested
if [ "${data.coder_parameter.install_extensions.value}" = "true" ]; then
  log_message "Installing VS Code extensions..."

  # Function to install an extension if not already installed
  install_extension() {
    extension=$1
    if ! code-server --list-extensions | grep -q "$extension"; then
      log_message "Installing extension: $extension"
      code-server --install-extension "$extension" || log_message "Failed to install $extension extension"
    else
      log_message "Extension already installed: $extension"
    fi
  }

  # List of extensions to install
  extensions=(
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    dsznajder.es7-react-js-snippets
    xabikos.JavaScriptSnippets
    formulahendry.auto-close-tag
    ms-vscode.vscode-typescript-tslint-plugin
    eg2.vscode-npm-script
    hwencc.html-tag-wrapper
    ritwickdey.liveserver
  )

  # Install extensions
  for extension in "$${extensions[@]}"; do
    install_extension "$extension"
  done

  # Create extensions.json for .vscode (extensions only)
  VSCODE_DIR="$HOME/${data.coder_workspace.me.name}/.vscode"
  mkdir -p "$VSCODE_DIR"
  VSCODE_EXTENSIONS_FILE="$VSCODE_DIR/extensions.json"

  # Generate the content for extensions.json with proper formatting
  generate_extensions_json() {
    local content="{\n  \"recommendations\": [\n"
    for ext in "$${extensions[@]}"; do
      content+="    \"$ext\",\n"
    done
    # Remove the trailing comma and newline
    content=$(echo -e "$content" | sed '$ s/,$//')
    content+="\n  ]\n}"
    echo -e "$content"
  }

  # Write the generated content to the file
  generate_extensions_json > "$VSCODE_EXTENSIONS_FILE"

  log_message "Created extensions.json with recommended extensions in $VSCODE_DIR"

  log_message "Extension installation completed."
else
  log_message "Extension installation skipped as per user preference."
fi

# Apply VS Code settings
log_message "Applying VS Code settings..."
SETTINGS_FILE="$HOME/.local/share/code-server/User/settings.json"

# Determine font settings
FONT_SETTINGS='"editor.fontFamily": "monospace",'
if [ -f "/tmp/font_name" ]; then
  FONT_NAME=$(cat /tmp/font_name | cut -d'=' -f2)
  FONT_SETTINGS='"editor.fontFamily": "'"$FONT_NAME"', monospace",'
fi
log_message "Applied font settings: $FONT_SETTINGS"

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
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "javascript.updateImportsOnFileMove.enabled": "always",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
EOF

log_message "VS Code settings applied successfully."
log_message "VS Code setup, font installation, and extension installation completed."
touch /tmp/vscode_setup_done
EOT

  depends_on = [coder_agent.main, coder_app.code-server]
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/${data.coder_workspace_owner.me.name}/${lower(data.coder_workspace.me.name)}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
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
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}"
  build {
    context = "./build"
    build_args = {
      USERNAME       = data.coder_workspace_owner.me.name
      INSTALL_ZSH    = data.coder_parameter.install_custom_zsh_env.value
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.main.name
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: KevinIsBetter@testing:~$
  hostname = data.coder_workspace.me.name
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  user       = data.coder_workspace_owner.me.name
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/${data.coder_workspace_owner.me.name}"
    volume_name    = docker_volume.home_volume.name
    read_only      = false
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
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
