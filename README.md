 Simple Antivirus

 1. Project Overview

This project uses Bash scripts to detect malicious files, quarantine them, and restore files when needed.

 Folder Hierarchy

    9638-lab2/
  ─ antivirusd.sh ─ restore.sh─ antivirus-cron.s─ Makefile ─ README.md ─ whitelist.txt
 
 2. Prerequisites

- Ubuntu Linux and Bash.
- `grep`, `find`, and other standard Linux utilities.
- `make` to use the Makefile.
- `cron` for Bonus 1.

Install the required tools:

    sudo apt update
    sudo apt install bash coreutils grep findutils make cron

Create the required directories and whitelist:

    mkdir -p testfiles quarantine
    touch whitelist.txt

Make the scripts executable:

    chmod +x antivirusd.sh antivirus-cron.sh

 3. Running the Scripts

 Part 1: Antivirus

    ./antivirusd.sh testfiles quarantine 7
Replace testfiles with the path of your source directory and quarantine with
 the path of your quarantine directory. The source directory must exist before
 running the scripts.
The script scans files and monitors the directory for changes.
Press Ctrl+C to stop it.

 Part 2: Restore

    bash ./restore.sh testfiles quarantine

Choose whether to restore a quarantined file, permanently delete it, or leave it unchanged.
Replace testfiles with the path of your source directory and quarantine with 
 the path of your quarantine directory. The source directory must exist before 
 running the scripts.

 Makefile

    make antivirus
    make restore

 4. Flagged Extensions and Keywords

The `is_malicious()` function in `antivirusd.sh` and `antivirus-cron.sh` defines the detection rules.

Extensions: `.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`

Keywords: `virus`, `trojan`, `malware`, `worm`, `ransomware`

Keywords are matched without case sensitivity.

 5. Bonus 1: Cron Job

Enable cron:

    sudo systemctl enable --now cron

Open the cron table:

    crontab -e

Add the following line, adjusting paths if necessary:

    * * * * * sleep 23; /home/afnan/9638-lab2/antivirus-cron.sh /home/afnan/9638-lab2/testfiles /home/afnan/9638-lab2/quarantine >> /home/afnan/9638-lab2/antivirus-cron.log 2>&1

Save and verify with:

    crontab -l

The job runs every minute and waits approximately 23 seconds before scanning.

 Every Third Friday at 12:31 AM

    31 0 * * 5 [ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ] && /path/to/your-command

Replace `/path/to/your-command` with the command to run.

 6. Bonus 2: Whitelist

When a file is restored, its filename is added to `whitelist.txt`.
Both antivirus scripts skip filenames listed in this file.

To add a filename manually:

    echo "example.txt" >> whitelist.txt

The whitelist persists between runs and matches filenames.

