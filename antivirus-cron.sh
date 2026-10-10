#!/bin/bash

dir="$1"
malicious_dir="$2"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
whitelist="$script_dir/whitelist.txt"
last_info="$script_dir/directory-info.cron.last"
new_info="$script_dir/directory-info.cron.new"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "Source directory does not exist: $dir"
    exit 1
fi

mkdir -p "$malicious_dir"

is_malicious() {
    local file="$1"
    local filename="${file##*/}"
    local extension="${filename##*.}"

    case "$filename" in
        *.*)
            case ".$extension" in
                .exe|.bat|.vbs|.scr|.ps1)
                    return 0
                    ;;
            esac
            ;;
    esac

    if grep -qiE 'virus|trojan|malware|worm|ransomware' -- "$file"; then
        return 0
    fi

    return 1
}

scan_directory() {
    while IFS= read -r -d '' file; do
        filename="${file##*/}"

        if [ -f "$whitelist" ] &&
           grep -Fxq -- "$filename" "$whitelist"; then
            continue
        fi

        if is_malicious "$file"; then
            echo "$filename is malicious and it is DELETED"

            if cp -- "$file" "$malicious_dir/"; then
                rm -- "$file"
            fi
        fi
    done < <(find "$dir" -maxdepth 1 -type f -print0)
}

if [ ! -f "$last_info" ]; then
    scan_directory
    ls -l "$dir" > "$last_info"
    exit 0
fi

ls -l "$dir" > "$new_info"

if ! cmp -s "$last_info" "$new_info"; then
    scan_directory
    ls -l "$dir" > "$last_info"
fi
