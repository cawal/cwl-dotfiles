# CWL Dotfiles - Agent Guidelines

## Repository Overview
Personal dotfiles for Linux desktop environment configuration using stow for symlink management.

## Build/Test/Lint Commands
```bash
# Main installation commands
make help                    # Show all available targets
make configure              # Link all configuration files using stow
make link-{component}       # Link specific component (qtile, i3, neovim, etc)

# Component-specific
make vi                     # Install and configure neovim
make qtile                  # Install qtile window manager
make i3                     # Install i3 window manager
cd i3/config && make create_config  # Build i3 config from templates
```

## Code Style Guidelines

### Python (qtile/neovim configs)
- Use snake_case for variables and functions
- Import order: standard library, third-party, local imports
- Use descriptive variable names (e.g., `load_config_banner`, `xresources`)
- Include docstrings for complex functions
- Use type hints where applicable

### Shell Scripts
- Use `#!/bin/bash` shebang
- Use shellcheck for linting
- Descriptive function and variable names
- Include error handling where appropriate

### Configuration Files
- Use consistent indentation (4 spaces for Python, 2 for configs)
- Comment complex configurations with inline explanations
- Group related settings together
- Use descriptive names for custom scripts (prefix with `cwl-`)

### File Organization
- Use stow for configuration management
- Place executable scripts in `bin/` directory
- Organize configs by application in separate directories
- Use `.gitignore` to exclude generated files and caches