# Advanced JavaScript Development Environment for Coder

## Overview

This project showcases an advanced JavaScript development environment template for Coder, demonstrating proficiency in containerization, infrastructure as code, and modern web development practices. It provides a customizable, reproducible workspace tailored for JavaScript and Node.js development.

![JavaScript and Node.js Logos](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Node.js_logo.svg/590px-Node.js_logo.svg.png?20170401104355)

## Key Features

- **Containerized JavaScript Workspace**: Utilizes Docker to create an isolated, consistent development environment for JavaScript and Node.js.
- **Node.js with NVM**: Installs Node.js using NVM for flexible version management.
- **Persistent Home Directory**: Implements Docker volumes to maintain user data and project files across workspace restarts.
- **Customizable Environment**: Offers options for installing a custom Zsh environment and Nerd Fonts.
- **VS Code Integration**: Seamlessly integrates with VS Code, including automatic installation of JavaScript-related extensions.
- **Resource Monitoring**: Implements custom scripts for monitoring CPU, RAM, and disk usage within the workspace.

## Prerequisites

1. A running Coder server (see [Coder's documentation](https://coder.com/docs/v2/latest/install) for installation instructions)
2. Docker installed and configured on the Coder server

## Usage

1. Import this template into your Coder deployment
2. Create a new workspace using this template
3. Configure workspace options:
   - Custom Zsh environment installation
   - Nerd Font selection
   - VS Code extensions installation

## Technical Highlights

### Infrastructure as Code
- Utilizes Terraform for provisioning and managing the development environment.
- Demonstrates advanced usage of Coder's Terraform provider.

### Docker Configuration
- Custom Dockerfile that sets up a robust JavaScript development environment:
  - Based on Ubuntu
  - Installs essential development tools
  - Sets up a non-root user with sudo privileges
  - Installs Node.js using NVM for version management
  - Configures Zsh with custom plugins (optional)
  - Installs global Node.js packages like TypeScript and Nodemon

### Workspace Customization
- Offers parameters for installing VS Code extensions and custom Zsh environments.
- Provides options for installing and configuring Nerd Fonts.

### VS Code Integration
- Automatically installs and configures JavaScript-related VS Code extensions.
- Sets up optimal editor settings for JavaScript development.

## Development Workflow

1. Connect to your workspace using SSH or the web IDE
2. Your persistent home directory is available for project files
3. Use Node.js, npm, and yarn for JavaScript development
4. Leverage installed VS Code extensions for enhanced productivity

## Security Considerations

- Implements proper user permissions and sudo access within the container.
- Avoids hardcoding sensitive information, using Coder's secure parameter handling.

## Skills Demonstrated

- Docker containerization for development environments
- Terraform and Infrastructure as Code
- JavaScript and Node.js ecosystem setup
- Shell scripting (Bash/Zsh)
- DevOps practices
- VS Code configuration and extension management

## Future Enhancements

- Implement support for multiple Node.js versions within the same workspace
- Add integration with popular JavaScript testing frameworks
- Include options for different package managers (npm, yarn, pnpm)
- Implement automatic project scaffolding for common JavaScript frameworks

## Contributing

Contributions to improve this template are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

---

For more information on using Coder, visit the [official documentation](https://coder.com/docs).