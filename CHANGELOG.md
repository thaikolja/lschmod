# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0

**Released:** November 27th, 2025

### Added

- Initial release of **lschmod**
- Displays directories and files in a tree structure with numeric chmod values
- Respects `.gitignore` by default (excludes matching files/directories)
- Excludes hidden files/directories by default
- Supports depth limiting with `-l`/`--levels` option
- Option to show hidden files with `-a`/`--all` option
- Option to ignore `.gitignore` with `-n`/`--no-gitignore` option
- Handles both single files and directories
