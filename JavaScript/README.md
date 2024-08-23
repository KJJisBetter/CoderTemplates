# Advanced Docker Development Environment for Coder

## Overview

This project showcases an advanced Docker-based development environment template for Coder, demonstrating proficiency in containerization, infrastructure as code, and DevOps practices. It provides a customizable, reproducible workspace that can be easily deployed and scaled.

## Key Features

- **Containerized Workspaces**: Utilizes Docker to create isolated, consistent development environments.
- **Persistent Home Directory**: Implements Docker volumes to maintain user data across workspace restarts.
- **Customizable Environment**: Offers options for installing custom Zsh environments and Nerd Fonts.
- **VS Code Integration**: Seamlessly integrates with VS Code, including automatic extension installation and configuration.
- **Resource Monitoring**: Implements custom scripts for monitoring CPU, RAM, and disk usage within the workspace.

## Technical Highlights

### Infrastructure as Code

- Utilizes Terraform for provisioning and managing the development environment.
- Demonstrates advanced usage of Coder's Terraform provider.

### Docker Configuration

- Custom Dockerfile that sets up a robust development environment:
  - Based on Ubuntu
  - Installs essential development tools
  - Sets up a non-root user with sudo privileges
  - Installs Node.js using NVM for version management
  - Configures Zsh with custom plugins (optional)
  - Installs global Node.js packages like TypeScript and Nodemon

### Workspace Customization

- Offers parameters for installing VS Code extensions and custom Zsh environments.
- Provides options for installing and configuring Nerd Fonts.

### Security Considerations

- Implements proper user permissions and sudo access.
- Avoids hardcoding sensitive information.

## Skills Demonstrated

- Docker containerization
- Terraform and Infrastructure as Code
- Shell scripting (Bash/Zsh)
- DevOps practices
- Environment customization and configuration management
- Integration with development tools (VS Code, Node.js)

## Future Enhancements

- Implement multi-stage Docker builds for optimized images
- Add support for additional development stacks (Python, Java, etc.)
- Integrate with CI/CD pipelines for automated testing and deployment
- Implement secret management for sensitive configuration
