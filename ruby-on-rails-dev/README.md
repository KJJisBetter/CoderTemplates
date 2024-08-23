# Ruby on Rails Development Environment with Docker

This Coder template provisions a Docker container tailored for Ruby on Rails development, providing a consistent and reproducible environment for your projects.

![Ruby on Rails Logo](https://rubyonrails.org/assets/images/opengraph.png)

## Features

- Ruby installation with customizable version
- Rails setup with optional new application creation
- PostgreSQL database integration (optional)
- Custom Zsh environment with productivity tools (optional, using [this script](https://github.com/KJJisBetter/personal-zsh-script))
- VS Code with Ruby extensions
- Persistent home directory

## Prerequisites

1. A running Coder server (see [Coder's documentation](https://coder.com/docs/v2/latest/install) for installation instructions)
2. Docker installed and configured on the Coder server

## Usage

1. Import this template into your Coder deployment
2. Create a new workspace using this template
3. Configure workspace options:
   - Ruby version
   - Rails application setup
   - Database choice
   - Custom Zsh environment
   - VS Code extensions

## Architecture

This template provisions:
- A custom Docker image (built locally)
- A Docker container (ephemeral)
- A Docker volume (persistent for `/home/{{workspace_owner}}`)

Note: Only the home directory persists between workspace restarts. To add permanent tools, modify the Dockerfile.

## Customization

### Modifying the Docker Image

1. Edit the `Dockerfile` in the `build` directory
2. Update the template:
   ```
   coder template push
   ```

### Environment Variables

Sensitive information and configuration options are managed through environment variables. Ensure these are set in your Coder deployment:

- `TF_VAR_project_id`: Your project ID for Vault integration
- Additional variables as needed (see `variables.tf`)

## Development Workflow

1. Connect to your workspace using SSH or the web IDE
2. Your Rails project will be available in the home directory
3. Use standard Rails and Ruby commands to develop your application

## Security Notes

- Workspace runs with privileged Docker permissions (necessary for certain development tasks)
- Sensitive information is managed through Coder's secret management and not stored in the template

## Contributing

Contributions to improve this template are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

---

For more information on using Coder, visit the [official documentation](https://coder.com/docs).
