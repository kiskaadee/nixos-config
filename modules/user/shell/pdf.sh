# --- PDF Utilities ---

pdf_dc() {
    local env_file="$HOME/Secrets/.env"
    local input_file="$1"
    local password="$2"

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

    if [[ -f "$output_file" ]]; then
        echo "Error: Output file '$output_file' already exists."
        read -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ "$overwrite" != "y" ]]; then
            echo "Operation cancelled."
            return 1
        fi
    fi

    echo "Decrypting $input_file..."
    if qpdf --password="$password" --decrypt "$input_file" "$output_file"; then
        echo "✅ Decryption successful: $output_file"
    else
        local exit_code=$?
        echo "❌ Decryption failed (qpdf exit code: $exit_code)"
        return $exit_code
    fi
}
