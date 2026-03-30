# Project Creator

A minimal Flutter desktop application that creates new projects from user-defined templates.

## Overview

It is primarily invoked via the OS file explorer context menu, receiving the output folder and the template name as launch arguments. It can also be launched standalone, in which case it prompts for both.

## Key Features

- Fast, guided UI to scaffold new projects from local templates.
- Support for any scripting language for the template entry point (`.dart`, `.sh`, `.ps1`, `.bat`).
- Dynamic wizard parameters defined via a `_parameters.json` file.
- Remembers user's last-used values per parameter per template.
- Cross-platform support for Windows, macOS, and Linux.

