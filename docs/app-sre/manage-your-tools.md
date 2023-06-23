# How to manage your tools efficiently

Managing tools and development languages versions is not a trivial task, especially when working in an environment with a diverse set of needs and languages.

Often times, package managers will only provide the latest version and that version may be incompatible with some projects

This document explains how to use the [asdf](https://asdf-vm.com/) tool to manage all your dependencies in an efficient and seamless way. That tool is similar to and inspired by other tools such as [rbenv](https://github.com/rbenv/rbenv), [goenv](https://github.com/syndbg/goenv), [tfenv](https://github.com/tfutils/tfenv) and others.

## Why use asdf?

* asdf exposes a common interface to managing tools on a global level or on a local level (per project).
* asdf is one of the most popular tool to manage tools runtimes, if not the most popular (over 17k starts on GitHub)
* asdf has a wide amount of community made plugins to support all kinds of tools and runtimes
* with a single file `.tool-versions` you can define a list of runtimes on a per-project basis or for your entire system. both can be used together nicely

# Installing asdf

asdf's [getting started](https://asdf-vm.com/guide/getting-started.html) page has instructions for virtually all platforms and all shell combinations

Here are instructions for the common ones used amonst engineers

1. Clone the asdf project

    ```sh
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.12.0
    ```

1. Add asdf to your shell

    ```sh
    # bash
    . "$HOME/.asdf/asdf.sh"
    . "$HOME/.asdf/completions/asdf.bash"
    
    # zsh
    . "$HOME/.asdf/asdf.sh"
    # for zsh completion, use oh-my-zsh's asdf plugin, or add the following somewhere in your custom zsh config
    fpath=(${ASDF_DIR}/completions $fpath)
    autoload -Uz compinit && compinit
    ```

1. Ensure the latest version is installed (optional, but recommended to do once in a while)

    ```sh
    asdf self-update
    ```

# Using asdf

## Install asdf plugins

The following installs plugins for common tools and runtimes used by SREs

The plugins catalog is available at [asdf-plugins](https://github.com/asdf-vm/asdf-plugins)

```sh
asdf plugin add golang
asdf plugin add nodejs
asdf plugin add python
asdf plugin add terraform
asdf plugin add vault
```

## Install tool versions

```sh
# List installed versions
# Versions set to be used globally or locally for the current directory will have a * beside them
asdf list
asdf list <name>

# List available versions
asdf list all <name>

# Install a specific version
asdf install python 3.9.17
asdf install terraform 1.4.6

# Show the latest verion
asdf latest --all
asdf latest <name>

# Install the latest version
asdf install python latest
```

## Use asdf-provided tools

**Setting a version globally or locally**
Both options will create or update a file `~/.tool-versions` or `$PWD/.tool-version` respectively
```sh
# Set a version to be used globally
asdf global python latest
asdf global python 3.11.4

# Set a version to be used for a given directory
cd to/the/project/directory
asdf local pythyon 3.9.17
```

## Use asdf in your projects

A file named `.tool-versions` can be added in a project's root directory (or subdirectories for more complex uses). That file can then list all tools and versions that are needed.

That file has a simple syntax which makes it easy to integrate and re-use into other tools (ci scripts, makefile)

```
golang 1.20.5
python 3.9.17
terraform 0.13.7
vault 1.14.0
```

The following will read the global `~/.tool-versions` and the local `$PWD/.tool-versions` (with priority) and will install all tool versions as defined, and will make them available from both the global and local directory contexts
```sh
cd to/the/project/directory
asdf install
```
