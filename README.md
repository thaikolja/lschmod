# lschmod

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-informational)](https://github.com/) [![Shell](https://img.shields.io/badge/Shell-Bash-blue)](https://www.gnu.org/software/bash/)

**lschmod** is a shell script for macOS and Linux that displays files and directories in a tree structure with their numeric `chmod` permissions (e.g,: `755`, `600`, etc.). This makes it easy to check permissions across multiple directories. See "[Usage](#usage)" to learn how to customize the script's behaviour.

## Features

- Displays directories and files in a tree structure with numeric `chmod` values
- Respects `.gitignore` (if exists) by default (excludes matching files/directories)
- Excludes hidden files/directories by default
- Supports depth limiting with `-l`/`--levels` option
- Option to show hidden files with `-a`/`--all` option
- Option to ignore .gitignore with `-n`/`--no-gitignore` option
- Handles both single files and directories

## Installation

### Manually

1. Download the `lschmod.sh` script
2. Make it executable: `chmod +x lschmod.sh`
3. (Optional) Rename it to be detected as a binary: `mv lschmod.sh lschmod`
4. Optionally, place it in your PATH for system-wide access

### Automatically

Use this one-line command to automate steps 1, 2, and 3. 

```bash
curl -Lo lschmod https://gitlab.com/thaikolja/lschmod/-/raw/main/lschmod.sh && chmod +x lschmod
```

> [!TIP]
>
> This command **does not** make this script system-wide (step 5). To do this, either copy the file into `/usr/local/bin/` **or** add it to your `$PATH` variable in your `.zshrc` (macOS) or `.bashrc` (Linux): `export PATH="/path/to/script/dir/:$PATH"`.

## Usage

```bash
./lschmod [OPTIONS] PATH
```

### Options

- `-a, --all`: Include hidden files and directories (starting with `.`)
- `-l, --levels N`: Limit the depth of the search to `N` levels
- `-n, --no-gitignore`: Do not respect `.gitignore` file

### Examples

```bash
# Show files in a directory (excluding hidden files and respecting .gitignore)
./lschmod /path/to/directory

# Show all files, including hidden ones
./lschmod -a /path/to/directory

# Show files up to 2 levels deep
./lschmod -l 2 /path/to/directory

# Show files but ignoring `.gitignore`
./lschmod -n /path/to/directory

# Show all files up to 3 levels deep, ignoring `.gitignore`
./lschmod -a -l 3 -n /path/to/directory
```

## Example Output

```bash
❯ lschmod . # Use `.` for current directory
755 .
        ├── 644 index.php
        ├── 644 license.txt
        ├── 644 readme.html
        ├── 644 wp-activate.php
        ├── 755 wp-admin/
    ├── 644 about.php
    ├── 644 admin-ajax.php
    ├── 644 admin-footer.php
    ├── 644 admin-functions.php
    ├── 644 admin-header.php
    ├── 644 admin-post.php
    ├── 644 admin.php
    ├── 644 async-upload.php
    ├── 644 authorize-application.php
    ├── 644 comment.php
    ├── 644 contribute.php
    ├── 644 credits.php
    ├── 755 css/
        ├── 644 about-rtl.css
        ├── 644 about-rtl.min.css
```

## Author

* Kolja Nolte (kolja.nolte@gmail.com)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.