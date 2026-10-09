#!/bin/bash

dir="$1"
malicious_dir="$2"
interval_secs="$3"
if [ "$#" -ne 3 ]; then
   echo "$0 dir malicious_dir interval_secs"
   exit 1
fi
is_malicious(){
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

scan_directory(){
    while IFS= read -r -d '' file;do
        if is_malicious "$file"; then
            filename="${file##*/}"

            echo "$filename  is malicious and it is deleted"
            if cp -- "$file" "$malicious_dir/"; then
                rm -- "$file"
            fi
       fi
    done < <(find "$dir" -maxdepth 1 -type f -print0)
}


last_info="directory-info.last"
new_info="directory-info.new"

scan_directory

ls -l "$dir" > "$last_info"

while true; do
    sleep "$interval_secs"
    ls -l "$dir" > "$new_info"
    if ! cmp -s "$last_info" "new_info"; then
       scan_directory
       ls -l "$dir" > "$last_info"
    fi
done
