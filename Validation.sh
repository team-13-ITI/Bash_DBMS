#!/bin/bash

# Function to validate names (for databases, tables, etc.)
validate_name() {
    local name="$1"
    local reserved_names=("admin" "root" "temp" "system")

    # Check if the name is empty
    if [[ -z "$name" ]]; then
        echo "Error: Name can't be empty."
        return 1
    fi

    # Verify if the name contains invalid characters (allow letters, numbers, underscores, and hyphens)
    if [[ "$name" =~ [[:space:]] || "$name" =~ [^a-zA-Z0-9_-] ]]; then
        echo "Error: Invalid name. Use only letters, numbers, underscores (_), and hyphens (-)."
        return 1
    fi

    # Verify if the name starts with a number or symbol
    if [[ "$name" =~ ^[0-9] || "$name" =~ ^[^a-zA-Z] ]]; then
        echo "Error: Name cannot start with a number or special symbol."
        return 1
    fi

    # Verify if the name is too long (max 255 characters)
    if [[ ${#name} -gt 255 ]]; then
        echo "Error: Name is too long. Maximum length is 255 characters."
        return 1
    fi

    # Check if the name is a reserved name
    for reserved_name in "${reserved_names[@]}"; do
        if [[ "$name" == "$reserved_name" ]]; then
            echo "Error: '$name' is a reserved name."
            return 1
        fi
    done

    return 0
}

# Function to check if the current user has write and execute permissions
check_permissions() {
    if [[ ! -w . || ! -x . ]]; then
        echo "Error: You do not have write or execute permissions in this directory."
        return 1
    fi
    return 0
}

# Function to check if a file exists and is executable
check_file_executable() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist."
        return 1
    fi
    if [[ ! -x "$file" ]]; then
        echo "Error: You do not have execute permission on '$file'."
        return 1
    fi
    return 0
}

# Function to check if a directory exists and is accessible
check_directory_access() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' does not exist."
        return 1
    fi
    if [[ ! -x "$dir" ]]; then
        echo "Error: You do not have execute permission on '$dir'."
        return 1
    fi
    return 0
}

# Function to validate if a table exists
validate_table_exists() {
    local table="$1"
    if [[ ! -f "$table" ]]; then
        echo "Error: Table '$table' does not exist."
        return 1
    fi
    return 0
}

# Function to validate if a table is writable
validate_writable() {
    local table="$1"
    if [[ ! -w "$table" ]]; then
        echo "Error: Table '$table' is not writable."
        return 1
    fi
    return 0
}

# Function to validate if the input data is not empty
validate_not_empty() {
    local data="$1"
    if [[ -z "$data" ]]; then
        echo "Error: Data can't be empty."
        return 1
    fi
    return 0
}

# Validate data format (check for numeric values)
validate_numeric_data() {
    local data="$1"
    if ! [[ "$data" =~ ^[0-9]+$ ]]; then
        echo "Error: Data should be numeric."
        return 1
    fi
    return 0
}

# Validate no duplicates in Insert
validate_no_duplicate_data() {
    local table="$1"
    local data="$2"
    if grep -q "^$data$" "$table"; then
        echo "Error: Data '$data' already exists in the table."
        return 1
    fi
    return 0
}

# Function to validate if a path contains invalid characters
validate_path() {
    local path="$1"
    if [[ "$path" =~ [[:space:]] || "$path" =~ [^a-zA-Z0-9/_-] ]]; then
        echo "Error: Path contains invalid characters."
        return 1
    fi
    return 0
}

# Function to validate if a database is empty before deletion
validate_database_empty() {
    local db="$1"
    if [[ -n "$(ls -A "$db")" ]]; then
        echo "Error: Database '$db' is not empty. Please delete its contents first."
        return 1
    fi
    return 0
}

# Function to validate if a string contains only alphanumeric characters and commas
validate_alphanumeric_comma() {
    local data="$1"
    if ! [[ "$data" =~ ^[a-zA-Z0-9,\ ]+$ ]]; then
        echo "Error: Data should be alphanumeric and comma-separated."
        return 1
    fi
    return 0
}

# Function to check if the current disk has enough space
check_disk_space() {
    # Minimum required space (in bytes)
    local required_space=10000000  
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt $required_space ]]; then
        echo "Error: Not enough disk space to create the database."
        return 1
    fi
    return 0
}

# Function to check if the user has sudo privileges
check_sudo_privileges() {
    if ! sudo -v &>/dev/null; then
        echo "Error: You need sudo privileges to perform this action."
        return 1
    fi
    return 0
}