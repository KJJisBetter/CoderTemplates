# Advanced Python Development Environment for Coder

## Overview

This project provides an advanced Python development environment template for Coder, demonstrating proficiency in containerization, infrastructure as code, and modern Python development practices. It offers a customizable, reproducible workspace tailored for Python development across various specializations.

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg" width="100" alt="Python Logo">
</div>

## Key Features

- **Containerized Python Workspace**: Utilizes Docker to create an isolated, consistent development environment for Python.
- **Customizable Python Version**: Allows selection of specific Python versions for project needs.
- **Multiple Development Environments**: Supports various Python ecosystems including general Python, Flask, Django, Data Science, and Machine Learning.
- **Virtual Environment Integration**: Automatically sets up a Python virtual environment for clean dependency management.
- **Persistent Home Directory**: Implements Docker volumes to maintain user data and project files across workspace restarts.
- **Customizable Shell Environment**: Offers options for installing a custom Zsh environment and Nerd Fonts.
- **VS Code Integration**: Seamlessly integrates with VS Code, including automatic installation of Python-related extensions.
- **Resource Monitoring**: Implements custom scripts for monitoring CPU, RAM, and disk usage within the workspace.

## Prerequisites

1. A running Coder server (see [Coder's documentation](https://coder.com/docs/v2/latest/install) for installation instructions)
2. Docker installed and configured on the Coder server

## Usage

1. Import this template into your Coder deployment
2. Create a new workspace using this template
3. Configure workspace options:
   - Python version
   - Development environment (General, Flask, Django, Data Science, Machine Learning)
   - Virtual environment name
   - Custom Zsh environment
   - Nerd Font selection

## Technical Highlights

### Infrastructure as Code

- Utilizes Terraform for provisioning and managing the development environment.
- Demonstrates advanced usage of Coder's Terraform provider.

### Docker Configuration

- Custom Dockerfile that sets up a robust Python development environment:
  - Based on official Python image with customizable version
  - Installs essential development tools
  - Sets up a non-root user with sudo privileges
  - Configures a Python virtual environment
  - Installs environment-specific packages (e.g., Flask, Django, data science libraries)
  - Configures Zsh with custom plugins (optional)

### Workspace Customization

- Offers parameters for installing VS Code extensions and custom Zsh environments.
- Provides options for installing and configuring Nerd Fonts.
- Allows selection of specific Python development environments.

### VS Code Integration

- Automatically installs and configures Python-related VS Code extensions.
- Sets up optimal editor settings for Python development.

## Development Workflow

1. Connect to your workspace using SSH or the web IDE
2. Your Python environment will be pre-configured in the home directory
3. Use standard Python commands and tools specific to your chosen environment
4. Leverage installed VS Code extensions for enhanced productivity

## Security Considerations

- Implements proper user permissions and sudo access within the container.
- Sensitive information is managed through Coder's secret management and not stored in the template.

## Customization

### Modifying the Template

1. Edit the `main.tf` file to change the Terraform configuration
2. Modify the `Dockerfile` in the `build` directory to adjust the container setup
3. Update the template in your Coder deployment:

   ```bash
   coder template push python-dev-env
   ```

   Replace `python-dev-env` with your template name

4. Create a new workspace or update an existing one to use the new template version

## Future Enhancements

- Implement multi-stage Docker builds for optimized images
- Add support for additional Python frameworks and libraries
- Integrate with CI/CD pipelines for automated testing and deployment
- Implement automatic backup and restore for project files

## Contributing

Contributions to improve this template are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

---

For more information on using Coder, visit the [official documentation](https://coder.com/docs).
