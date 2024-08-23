# Advanced Ruby on Rails Development Environment for Coder

## Overview

This project showcases an advanced Ruby on Rails development environment template for Coder, demonstrating proficiency in containerization, infrastructure as code, and modern web development practices. It provides a customizable, reproducible workspace tailored for Ruby on Rails development.

<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/73/Ruby_logo.svg" width="100" alt="Ruby Logo">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://upload.wikimedia.org/wikipedia/commons/6/62/Ruby_On_Rails_Logo.svg" width="150" alt="Ruby on Rails Logo">
</div>

## Key Features

- **Containerized Ruby on Rails Workspace**: Utilizes Docker to create an isolated, consistent development environment for Ruby and Rails.
- **Customizable Ruby Version**: Allows selection of specific Ruby versions for project needs.
- **Rails Application Setup**: Option to create a new Rails application or use an existing one.
- **Database Integration**: Supports PostgreSQL database integration with secure configuration.
- **Persistent Home Directory**: Implements Docker volumes to maintain user data and project files across workspace restarts.
- **Customizable Environment**: Offers options for installing a custom Zsh environment and Nerd Fonts.
- **VS Code Integration**: Seamlessly integrates with VS Code, including automatic installation of Ruby-related extensions.
- **Resource Monitoring**: Implements custom scripts for monitoring CPU, RAM, and disk usage within the workspace.

## Prerequisites

1. A running Coder server (see [Coder's documentation](https://coder.com/docs/v2/latest/install) for installation instructions)
2. Docker installed and configured on the Coder server

## Usage

1. Import this template into your Coder deployment
2. Create a new workspace using this template
3. Configure workspace options:
   - Ruby version
   - Rails application setup
   - Database choice (PostgreSQL or SQLite)
   - Custom Zsh environment
   - VS Code extensions for Ruby development

## Technical Highlights

### Infrastructure as Code

- Utilizes Terraform for provisioning and managing the development environment.
- Demonstrates advanced usage of Coder's Terraform provider.

### Docker Configuration

- Custom Dockerfile that sets up a robust Ruby on Rails development environment:
  - Based on official Ruby image with customizable version
  - Installs essential development tools and database clients
  - Sets up a non-root user with sudo privileges
  - Installs Rails and other commonly used gems
  - Configures Zsh with custom plugins (optional)

### Workspace Customization

- Offers parameters for installing VS Code extensions and custom Zsh environments.
- Provides options for installing and configuring Nerd Fonts.
- Allows selection of database type and Rails application setup.

### VS Code Integration

- Automatically installs and configures Ruby-related VS Code extensions.
- Sets up optimal editor settings for Ruby and Rails development.

## Development Workflow

1. Connect to your workspace using SSH or the web IDE
2. Your Rails project will be available in the home directory
3. Use standard Rails and Ruby commands to develop your application
4. Leverage installed VS Code extensions for enhanced productivity

## Security Considerations

- Implements proper user permissions and sudo access within the container.
- Sensitive information is managed through Coder's secret management and not stored in the template.
- PostgreSQL setup includes secure credential management.

## Skills Demonstrated

- Docker containerization for development environments
- Terraform and Infrastructure as Code
- Ruby on Rails ecosystem setup
- Shell scripting (Bash/Zsh)
- DevOps practices
- VS Code configuration and extension management
- Database integration and security practices

## Customization

### Modifying the Template

### Modifying the Template

1. Edit the `main.tf` file to change the Terraform configuration
2. Modify the `Dockerfile` in the `build` directory if you need to change the container setup
3. Update the template in your Coder deployment using one of these methods:

   a. Using the CLI:

   ```bash
   coder template push ruby-on-rails-dev
   ```

   Replace ruby-on-rails-dev with the actual name of your template

   b. Using the Web UI:

   - Navigate to the template in the Coder web interface
   - Click on "Build" to create a new version
   - Review the changes and click "Publish" to make the new version available

4. Create a new workspace or update an existing one to use the new template version

### Environment Variables

Sensitive information and configuration options are managed through environment variables. Ensure these are set in your Coder deployment:

- `TF_VAR_project_id`: Your project ID for Vault integration
- Additional variables as needed (see `variables.tf`)

## Future Enhancements

- Implement multi-stage Docker builds for optimized images
- Add support for additional databases (MySQL, MongoDB)
- Integrate with CI/CD pipelines for automated testing and deployment
- Implement automatic backup and restore for databases

## Contributing

Contributions to improve this template are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

[MIT License](LICENSE)

---

For more information on using Coder, visit the [official documentation](https://coder.com/docs).
