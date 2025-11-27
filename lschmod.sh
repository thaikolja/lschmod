#!/bin/bash

# lschmod.sh is a bash script that displays file and directory structures
# with their numeric chmod permissions, respecting .gitignore patterns and
# offering customizable options.
#
# Copyright (c) 2025 Kolja Nolte <kolja.nolte@gmail.com>
#
# Author:         Kolja Nolte
# E-Mail:         kolja.nolte@gmail.com
# License:        MIT (https://opensource.org/licenses/MIT)
# Version:        1.0.0
# Repository:     https://gitlab.com/thaikolja/lschmod

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] PATH"
    echo "  PATH: Directory or file to show"
    echo "  OPTIONS:"
    echo "    -a, --all: Include hidden files and directories (starting with .)"
    echo "    -l, --levels N: Limit the depth of the search to N levels"
    echo "    -n, --no-gitignore: Do not respect .gitignore file"
    echo ""
    echo "Examples:"
    echo "  $0 -a /path/to/directory                  # Show all files including hidden ones"
    echo "  $0 -l 2 /path/to/directory                # Show files up to 2 levels deep"
    echo "  $0 -a -l 3 /path/to/directory             # Show all files up to 3 levels deep"
    echo "  $0 -n /path/to/directory                  # Show files ignoring .gitignore"
    echo "  $0 /path/to/directory                     # Show files excluding hidden ones, respecting .gitignore, unlimited depth"
    exit 1
}

# Function to get numeric chmod value
get_chmod_numeric() {
    local file="$1"
    local perms=""
    # Use stat to get the octal permission value directly
    # This works on both Linux (with %a) and macOS (with -f %OLp)
    if stat --version &>/dev/null 2>&1; then
        # Linux version
        perms=$(stat -c "%a" "$file" 2>/dev/null)
    else
        # macOS/BSD version
        perms=$(stat -f "%OLp" "$file" 2>/dev/null)
    fi
    echo "$perms"
}

# Function to check if a path should be ignored based on .gitignore patterns
should_ignore() {
    local path="$1"
    local base_name=""
    base_name=$(basename "$path")
    
    # Always ignore venv directories
    if [[ "$path" =~ /venv(/|$) ]] || [[ "$base_name" == "venv" ]]; then
        return 0  # 0 means "should ignore"
    fi
    
    # If no .gitignore exists or ignore_gitignore is true, don't ignore anything else
    if [ ! -f ".gitignore" ] || [ "$ignore_gitignore" = true ]; then
        return 1  # 1 means "should not ignore"
    fi
    
    # Get the relative path from the current directory
    local rel_path="${path#./}"
    
    # Check against .gitignore patterns
    while IFS= read -r pattern; do
        # Skip empty lines and comments
        [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
        
        # Remove leading/trailing whitespace
        pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip if pattern is empty after cleaning
        [[ -z "$pattern" ]] && continue
        
        # Handle directory patterns (ending with /)
        if [[ "$pattern" == */ ]]; then
            pattern="${pattern%/}"
            # Match directories and their contents
            if [[ "$rel_path" == "$pattern"/* || "$rel_path" == "$pattern" ]]; then
                return 0
            fi
        # Handle negation patterns (starting with !)
        elif [[ "$pattern" == !* ]]; then
            # This is a negation pattern - don't ignore if there's a match
            local neg_pattern="${pattern#!}"
            if [[ "$rel_path" == "$neg_pattern" || "$rel_path" == "$neg_pattern"/* || "$base_name" == "$neg_pattern" ]]; then
                return 1  # Don't ignore
            fi
        else
            # Handle regular patterns
            # Check for exact match
            if [[ "$rel_path" == "$pattern" ]]; then
                return 0
            fi
            # Check for basename match (for patterns without /)
            if [[ "$pattern" != */* && "$base_name" == "$pattern" ]]; then
                return 0
            fi
            # Check for path ending with pattern
            if [[ "$rel_path" == */"$pattern" ]]; then
                return 0
            fi
        fi
    done < ".gitignore"
    
    return 1  # Don't ignore
}

# Initialize flags
show_hidden=false
max_levels=""
ignore_gitignore=false
target_path=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            show_hidden=true
            shift
            ;;
        -l|--levels)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                max_levels="$2"
                shift 2
            else
                echo "Error: --levels requires a numeric argument" >&2
                usage
            fi
            ;;
        -n|--no-gitignore)
            ignore_gitignore=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            if [ -z "$target_path" ]; then
                target_path="$1"
            else
                echo "Too many arguments" >&2
                usage
            fi
            shift
            ;;
    esac
done

# Check if target path is provided
if [ -z "$target_path" ]; then
    echo "Error: No path provided" >&2
    usage
fi

if [ ! -e "$target_path" ]; then
    echo "Error: Path does not exist: $target_path" >&2
    exit 1
fi

if [ -f "$target_path" ]; then
    # Handle single file
    chmod_val=$(get_chmod_numeric "$target_path")
    echo "$chmod_val $target_path"
    exit 0
elif [ -d "$target_path" ]; then
    # Change to the target directory to properly process .gitignore
    original_dir=$(pwd)
    cd "$target_path" || exit 1
    
    # Output the root directory
    root_perms=$(get_chmod_numeric ".")
    root_name=$(basename "$target_path")
    echo "$root_perms $root_name"
    
    # Create a temporary file to store all items
    temp_file=$(mktemp)
    
    # Build find command based on whether to show hidden files and max levels
    if [ "$show_hidden" = true ]; then
        # Include hidden files
        if [ -n "$max_levels" ]; then
            find . -mindepth 1 -maxdepth "$max_levels" -not -path "./." | sort > "$temp_file"
        else
            find . -mindepth 1 -not -path "./." | sort > "$temp_file"
        fi
    else
        # Exclude hidden files and directories (those starting with .)
        if [ -n "$max_levels" ]; then
            find . -mindepth 1 -maxdepth "$max_levels" -not -path "./." -not -path "./.*" -not -path "./.*/" -not -path "*/.*/.*" | sort > "$temp_file"
        else
            find . -mindepth 1 -not -path "./." -not -path "./.*" -not -path "./.*/" -not -path "*/.*/.*" | sort > "$temp_file"
        fi
    fi
    
    # Process each item from the temporary file
    while IFS= read -r item; do
        # Skip empty lines
        [ -z "$item" ] && continue
        
        # If not showing hidden and the item is hidden, skip it
        if [ "$show_hidden" = false ]; then
            # Check if any part of the path is a hidden file/directory
            IFS='/' read -ra path_parts <<< "${item#./}"
            is_hidden=false
            for part in "${path_parts[@]}"; do
                if [[ "$part" == .* ]]; then
                    is_hidden=true
                    break
                fi
            done
            if [ "$is_hidden" = true ]; then
                continue
            fi
        fi
        
        # Check if the item should be ignored based on .gitignore
        if ! should_ignore "$item"; then
            # Calculate depth for tree-like indentation by counting path separators
            item_path="${item#./}"  # Remove leading ./
            depth=$(echo "$item_path" | grep -o "/" | wc -l)
            indent=$(printf '    %.0s' $(seq 1 "$depth"))
            
            # Determine the tree symbol
            if [ "$depth" -eq 0 ]; then
                symbol="├──"
            else
                symbol="├──"
            fi
            
            # Get permissions
            perms=$(get_chmod_numeric "$item")
            
            # Print with indentation, symbol, permissions, and name
            item_name=$(basename "$item")
            if [ -d "$item" ]; then
                echo "${indent}${symbol} $perms $item_name/"
            else
                echo "${indent}${symbol} $perms $item_name"
            fi
        fi
    done < "$temp_file"
    
    # Clean up
    rm "$temp_file"
    
    # Return to original directory
    cd "$original_dir" || exit 1
else
    echo "Error: Path is neither a file nor a directory: $target_path" >&2
    exit 1
fi