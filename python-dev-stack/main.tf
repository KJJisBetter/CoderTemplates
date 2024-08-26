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

data "coder_parameter" "python_version" {
  name         = "python_version"
  display_name = "Python Version"
  description  = "Specify the Python version to install (e.g., 3.12.0, 3.11.4) or leave blank for latest"
  type         = "string"
  default      = ""
  validation {
    regex = "^$|^\\d+\\.\\d+\\.\\d+$"
    error = "Please enter a valid Python version in the format X.X.X (e.g., 3.12.0) or leave blank for latest"
  }
  mutable = true
  icon    = "https://raw.githubusercontent.com/devicons/devicon/master/icons/python/python-original.svg"
  order   = 1
}


data "coder_parameter" "development_environment" {
  name         = "development_environment"
  display_name = "Development Environment"
  description  = "Choose the type of development environment you want to set up"
  type         = "string"
  default      = "general"
  icon         = "https://cdn-icons-png.flaticon.com/512/5968/5968350.png"
  mutable      = true
  order        = 2
  option {
    name  = "General Python"
    value = "general"
    icon  = "https://cdn-icons-png.flaticon.com/512/5968/5968350.png"
  }
  option {
    name  = "Flask"
    value = "flask"
    icon  = "https://cdn.worldvectorlogo.com/logos/flask.svg"
  }
  option {
    name  = "Django"
    value = "django"
    icon  = "https://cdn.worldvectorlogo.com/logos/django.svg"
  }
  option {
    name  = "Data Science"
    value = "data_science"
    icon  = "https://cdn-icons-png.flaticon.com/512/2103/2103665.png"
  }
  option {
    name  = "Machine Learning"
    value = "machine_learning"
    icon  = "https://cdn-icons-png.flaticon.com/512/2103/2103633.png"
  }
}

data "coder_parameter" "venv_name" {
  name         = "venv_name"
  display_name = "Virtual Environment Name"
  description  = "Name of the Python virtual environment (leave blank for 'venv')"
  type         = "string"
  default      = "venv"
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
  description  = "Enter the path to the .ttf file from the Nerd Fonts repository (required if Custom font is selected)"
  type         = "string"
  default      = ""  // Allow empty string as default
  mutable      = true
  order        = 6
}

locals {
  username = data.coder_workspace_owner.me.name
  workspace_dir = "/home/${local.username}/${data.coder_workspace.me.name}"
  home_dir = "/home/${local.username}"
}

data "coder_provisioner" "me" {
}

provider "docker" {
}

data "coder_workspace" "me" {
}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Prepare user home with default files on first start.
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # Install the latest code-server.
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone                           

    # Create a script to activate the virtual environment
    cat <<EOF > ~/activate_venv.sh
#!/bin/bash
source /home/${local.username}/${data.coder_parameter.venv_name.value}/bin/activate
EOF

    chmod +x ~/activate_venv.sh

    # Create a welcome message
    cat <<EOF > ~/welcome.txt
Welcome to your Coder workspace!

To activate your Python virtual environment, run:
    source ~/activate_venv.sh

Happy coding!
EOF

    # Display the welcome message
    echo "cat ~/welcome.txt" >> ~/.bashrc

    # Start code-server in the background.
    /home/${data.coder_workspace_owner.me.name}/.local/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT


  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
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


resource "coder_script" "vscode_setup" {
  agent_id     = coder_agent.main.id
  display_name = "Install VS Code Extensions and Configure Settings"
  run_on_start = true
  icon         = "/icon/vscode.svg"
  script = <<EOT
#!/bin/bash
set -euo pipefail

log_message() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /tmp/vscode_setup.log
}

log_message "Starting VS Code setup and extension installation..."

# Ensure code-server is in the PATH and running
export PATH="$HOME/.local/bin:$PATH"

log_message "Waiting for code-server to be ready..."
timeout 60s bash -c 'until pgrep -f code-server > /dev/null; do sleep 2; done'
if [ $? -ne 0 ]; then
  log_message "Timeout waiting for code-server to start. Exiting."
  exit 1
fi
sleep 10  # Give code-server a moment to fully initialize

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
  FONT_NAME=$(echo "$FONT_FILE" | sed -E 's/(.*)NerdFont.*\.ttf/\1/' | sed -E 's/([a-z])([A-Z])/\1 \2/g' | sed -E 's/([A-Z])([A-Z][a-z])/\1 \2/g' | sed 's/^ *//' | sed 's/ *$//' | sed 's/Fira Code/FiraCode/')
  echo "FONT_NAME=$FONT_NAME" > /tmp/font_name
  log_message "Extracted font name: $FONT_NAME"
else
  log_message "No font installation required."
fi

# Install Python extensions
log_message "Installing Python extensions..."

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

# Base extensions for all Python environments
base_extensions=(
  "ms-python.python"
  "njpwerner.autodocstring"
  "kevinrose.vsc-python-indent"
  "littlefoxteam.vscode-python-test-adapter"
  "njqdev.vscode-python-typehint"
  "visualstudioexptteam.vscodeintellicode"
  "aaron-bond.better-comments"
  "almenon.arepl"
  "deerawan.vscode-dash"
)

# Install base extensions
for extension in "$${base_extensions[@]}"; do
  install_extension "$extension"
done

# Additional extensions based on the development environment
case "${data.coder_parameter.development_environment.value}" in
  "flask")
    install_extension "wholroyd.jinja"
    ;;
  "django")
    install_extension "batisteo.vscode-django"
    ;;
  "data_science" | "machine_learning")
    install_extension "ms-toolsai.jupyter"
    install_extension "ms-toolsai.datascience"
    ;;
esac

log_message "Extension installation completed."

# Determine font settings
FONT_SETTINGS='"editor.fontFamily": "monospace",'
if [ -f "/tmp/font_name" ]; then
  FONT_NAME=$(cat /tmp/font_name | cut -d'=' -f2)
  FONT_SETTINGS='"editor.fontFamily": "'"$FONT_NAME"' Nerd Font, monospace",'
  log_message "Applied font settings: $FONT_SETTINGS"
fi

# Apply VS Code settings
log_message "Applying VS Code settings..."
SETTINGS_FILE="$HOME/.local/share/code-server/User/settings.json"

# Create or update settings file
cat > "$SETTINGS_FILE" <<EOF
{
  "workbench.colorTheme": "Default Dark+",
  "editor.fontSize": 14,
  "terminal.integrated.fontSize": 14,
  $FONT_SETTINGS
  "editor.tabSize": 4,
  "editor.rulers": [80, 120],
  "files.trimTrailingWhitespace": true,
  "python.languageServer": "Default",
  "python.formatting.provider": "black",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  },
  "autoDocstring.docstringFormat": "google",
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": true,
  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.autoImportCompletions": true,
  "editor.suggestSelection": "first",
  "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
  "arepl.pythonExePath": "${data.coder_parameter.venv_name.value}/bin/python",
  "python.defaultInterpreterPath": "${data.coder_parameter.venv_name.value}/bin/python"
}
EOF

log_message "VS Code settings applied successfully."
log_message "VS Code setup and extension installation completed."
touch /tmp/vscode_setup_done
EOT
}


resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = data.coder_parameter.development_environment.value == "general" ? "http://localhost:13337/?folder=${local.workspace_dir}" : "http://localhost:13337/?folder=${local.workspace_dir}/${data.coder_parameter.venv_name.value}"
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
      USER = local.username
      PYTHON_VERSION = data.coder_parameter.python_version.value != "" ? data.coder_parameter.python_version.value : null
      DEV_ENV = data.coder_parameter.development_environment.value
      WORKSPACE_NAME = data.coder_workspace.me.name
      VENV_NAME = data.coder_parameter.venv_name.value
      INSTALL_ZSH = data.coder_parameter.install_custom_zsh_env.value
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1(f)]))
    python_version = data.coder_parameter.python_version.value
    dev_env = data.coder_parameter.development_environment.value
    venv_name = data.coder_parameter.venv_name.value
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.main.name
  name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = local.home_dir
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