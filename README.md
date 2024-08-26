# Coder Development Environment Templates

## Overview

This project provides a collection of advanced development environment templates for Coder, demonstrating proficiency in containerization, infrastructure as code, and modern development practices across multiple programming languages and frameworks. These templates offer customizable, reproducible workspaces tailored for Python, Ruby on Rails, and JavaScript development.

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg" width="100" alt="Python Logo">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/73/Ruby_logo.svg" width="100" alt="Ruby Logo">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png" width="100" alt="JavaScript Logo">
</div>

## Templates

1. [Advanced Python Development Environment](#python-environment)
2. [Advanced Ruby on Rails Development Environment](#ruby-on-rails-environment)
3. [Advanced JavaScript Development Environment](#javascript-environment)

## Common Features

All templates share the following features:

- **Containerized Workspaces**: Utilize Docker to create isolated, consistent development environments.
- **Persistent Home Directory**: Implement Docker volumes to maintain user data and project files across workspace restarts.
- **Customizable Environment**: Offer options for installing custom Zsh environments and Nerd Fonts.
- **VS Code Integration**: Seamlessly integrate with VS Code, including automatic installation of language-specific extensions.
- **Resource Monitoring**: Implement custom scripts for monitoring CPU, RAM, and disk usage within the workspace.

## Prerequisites

1. A running Coder server (see [Coder's documentation](https://coder.com/docs/v2/latest/install) for installation instructions)
2. Docker installed and configured on the Coder server

## Usage

1. Import the desired template into your Coder deployment
2. Create a new workspace using the chosen template
3. Configure workspace options as prompted

## Template-Specific Features

### Python Environment

- Customizable Python version
- Multiple development environments (General, Flask, Django, Data Science, Machine Learning)
- Virtual environment integration

### Ruby on Rails Environment

- Customizable Ruby version
- Rails application setup options
- Database integration (PostgreSQL or SQLite)

### JavaScript Environment

- Node.js with NVM for version management
- Global installation of common packages (TypeScript, Nodemon)

## Technical Highlights

- **Infrastructure as Code**: Utilizes Terraform for provisioning and managing development environments.
- **Docker Configuration**: Custom Dockerfiles that set up robust language-specific development environments.
- **Workspace Customization**: Offers parameters for installing VS Code extensions, custom Zsh environments, and Nerd Fonts.
- **VS Code Integration**: Automatically installs and configures language-specific VS Code extensions.

## Security Considerations

- Implements proper user permissions and sudo access within containers.
- Manages sensitive information through Coder's secret management.
- Avoids hardcoding sensitive data in templates.

## Customization

### Modifying Templates

1. Edit the `main.tf` file to change the Terraform configuration
2. Modify the `Dockerfile` in the respective `build` directory to adjust the container setup
3. Update the template in your Coder deployment:

   ```bash
   coder template push <template-name>
   ```

   Replace `<template-name>` with the actual name of your template

4. Create a new workspace or update an existing one to use the new template version

## Contributing

Contributions to improve these templates are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

---

For more information on using Coder, visit the [official documentation](https://coder.com/docs).