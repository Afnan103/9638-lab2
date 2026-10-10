
#!/bin/bash

dir="$1"
malicious_dir="$2"


if [ -z "$(find "$malicious_dir" -maxdepth 1 -type f -print -quit)" ]; then
    echo "No malicious files to review."
    exit 0
fi

while true; do

    
    files=("$malicious_dir"/*)

    
    if [ ! -f "${files[0]}" ]; then
        echo "No malicious files to review."
        break
    fi

    echo "Files in quarantine:"
    for i in "${!files[@]}"; do
        echo "$((i + 1)). $(basename "${files[$i]}")"
    done

    read -r -p "Choose a file number (0 to exit): " choice

    if [ "$choice" = "0" ]; then
        break
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] ||
       [ "$choice" -lt 1 ] ||
       [ "$choice" -gt "${#files[@]}" ]; then
        echo "Invalid choice."
        continue
    fi

    selected_file="${files[$((choice - 1))]}"
    filename=$(basename "$selected_file")

    echo "1. Restore this file"
    echo "2. Permanently delete this file"
    echo "3. Leave this file as-is"

    read -r -p "Choose an option: " option

    case "$option" in
        1)
            if mv -- "$selected_file" "$dir/"; then
                echo "Restored $filename to $dir."
            fi
            ;;
        2)
            if rm -- "$selected_file"; then
                echo "$filename permanently deleted."
            fi
            ;;
        3)
            continue
            ;;
        *)
            echo "Invalid option."
            ;;
    esac

done
