# 📄 Command Line PDF Utilities
# Sourced in .bashrc to provide quick file operations on PDF documents.

# 1. pdf_dc: Decrypts a password-protected PDF document.
# Uses 'qpdf' under the hood. Automatically searches for a default password ("defpass") 
# in the user's local secrets environment file (`~/Secrets/.env`) if no password argument is supplied.
pdf_dc() {
    local env_file="$HOME/Secrets/.env"
    local input_file="$1"
    local password="$2"

    # Attempt to auto-load password from environment if none was provided on the CLI
    if [[ -z "$password" ]]; then
        if [[ -f "$env_file" ]]; then
            local defpass
            defpass=$(rg "^defpass=" "$env_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
            password="${defpass}"
        fi
    fi

    if [[ -z "$password" ]]; then
        echo "Error: No password provided and 'defpass' not found in .env" >&2
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file '$input_file' not found" >&2
        return 1
    fi

    local output_file="${input_file%.pdf}_decrypted.pdf"

    # Handle file overwrite prompts
    if [[ -f "$output_file" ]]; then
        echo "Error: Output file '$output_file' already exists."
        read -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ "$overwrite" != "y" ]]; then
            echo "Operation cancelled."
            return 1
        fi
    fi

    echo "Decrypting $input_file..."
    # Execute qpdf tool to perform decryption
    if qpdf --password="$password" --decrypt "$input_file" "$output_file"; then
        echo "✅ Decryption successful: $output_file"
    else
        local exit_code=$?
        echo "❌ Decryption failed (qpdf exit code: $exit_code)"
        return $exit_code
    fi
}
