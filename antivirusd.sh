#!/bin/bash

dir="$1"
malicious_dir="$2"
interval_secs="$3"
whitelist="whitelist.txt"

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval_secs"
    exit 1
fi

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

scan() {
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

last_info="directory-info.last"
new_info="directory-info.new"


scan

ls -l "$dir" > "$last_info"


while true; do
    sleep "$interval_secs"

    ls -l "$dir" > "$new_info"

    if ! cmp -s "$last_info" "$new_info"; then
        scan
        cp "$new_info" "$last_info"
    fi
done
