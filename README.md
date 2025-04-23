# AutoEnvs 🚀

> Seamlessly manage development environments across projects

## What is AutoEnvs?

AutoEnvs is a lightweight ZSH plugin that automatically detects and activates project-specific environments when you navigate between directories. It handles:

- 📋 `.env` file sourcing
- 🐍 Python virtual environments
- 🔄 Environment variable management

## Why I Made This

Managing multiple development environments across projects is tedious and error-prone. Every time you switch between codebases, you need to:

- Source the correct `.env` files
- Activate the appropriate virtual environments
- Set up language-specific tooling
- Remember to clean up when switching contexts

**AutoEnvs solves this problem** by automating environment transitions. When you change directories, it intelligently handles environment setup and teardown, letting you focus on writing code instead of managing shell state.

## Features

- **Automatic environment detection**: Activates environments when you `cd` into a project directory
- **Smart environment cleanup**: Properly deactivates previous environments when switching contexts
- **Permission management**: Asks for confirmation before sourcing files, with options to always allow or deny
- **Stacked environments**: Maintains a stack of activated environments for proper cleanup
- **VS Code compatibility**: Detects and adjusts behavior when running in VS Code integrated terminals

## Installation

### Using Oh My Zsh

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/autoenvs.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoenvs
   ```

2. Add the plugin to your `.zshrc`:
   ```
   plugins=(... autoenvs)
   ```

3. Restart your terminal or run `source ~/.zshrc`

### Manual Installation

1. Clone the repository to your preferred location:
   ```
   git clone https://github.com/yourusername/autoenvs.git ~/.autoenvs
   ```

2. Add the following to your `.zshrc`:
   ```
   source ~/.autoenvs/autoenvs.plugin.zsh
   ```

3. Restart your terminal or run `source ~/.zshrc`

## Usage

Just navigate to your project directories as usual. AutoEnvs will:

1. Detect `.env` files and virtual environments
2. Ask for permission to activate them (first time only)
3. Remember your preferences for future visits
4. Automatically clean up when you leave the directory

## Configuration

Customize AutoEnvs by setting these variables in your `.zshrc` before loading the plugin:

```zsh
# Default locations to look for
ZSH_DOTENV_FILE=.env        # Name of environment file
ZSH_VENV_DIR=.venv          # Name of virtual environment directory

# Permission lists
ZSH_DOTENV_ALLOWED_LIST="${ZSH_CACHE_DIR:-$ZSH/cache}/dotenv-allowed.list"
ZSH_DOTENV_DISALLOWED_LIST="${ZSH_CACHE_DIR:-$ZSH/cache}/dotenv-disallowed.list"
ZSH_VENV_ALLOWED_LIST="${ZSH_CACHE_DIR:-$ZSH/cache}/venv-allowed.list"
ZSH_VENV_DISALLOWED_LIST="${ZSH_CACHE_DIR:-$ZSH/cache}/venv-disallowed.list"
```

## License

This project is licensed under the GNU GPL License - see the [LICENSE](LICENSE) file for details. 