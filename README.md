# Update Checker

A small PowerShell script that tracks installed software versions in a text file, checks vendor web pages for newer versions, and tells you whether each item is up to date.[11]

## Features

- Stores software list (name, vendor URL, current version) in `C:\temp\updateList.txt`.[11]
- Interactive prompts to add or modify software entries.[11]
- Uses `Invoke-WebRequest` to fetch each vendor page and regex to detect the latest version string.[12]
- Color-coded console output with optional timestamped error logging to `C:\temp\debug.txt`.[13]

## Requirements

- Windows with PowerShell (tested with Windows PowerShell 5.x; compatible with typical PowerShell core features like `Invoke-WebRequest` and `Out-ConsoleGridView`).[13]
- Directory `C:\temp\` must exist and be writable for `updateList.txt` and `debug.txt`.[14]
- Internet connectivity to reach each software vendor URL.[15]

## Installation

1. Create the folder if needed:  
   - `New-Item -Path 'C:\temp' -ItemType Directory -Force`  
2. Clone this repository:  
   - `git clone https://github.com/<your-account>/update-checker.ps1.git`  
3. Open a PowerShell prompt in the repo directory.  
4. If needed, relax execution policy (in an elevated PowerShell window):  
   - `Set-ExecutionPolicy RemoteSigned`[13]

## Usage

1. Run the script:  
   - `.\UpdateChecker.ps1`  
2. Follow the prompt:  
   - Type “add” to add new software: you will be asked for Software name, Website URL, and your current version.[11]
   - Type “modify” to open a grid view of all entries, select one, and edit Software/Link/Version.[11]
   - Any other input shows the full list and asks you to confirm it; answer “yes” to proceed or anything else to exit.[11]
3. After confirmation, the script:  
   - Clears `C:\temp\updateList.txt`.  
   - For each software entry, requests the configured URL, searches the HTML content for a `version X.X.X` pattern, and extracts the numeric version.[12]
   - Compares the detected latest version with your stored version and prints:  
     - Green message if your version matches.  
     - Yellow warning if the site shows a newer version.[11]
   - Writes all current entries (Software, Link, Version) back to `updateList.txt`.[11]

## Script structure

- `updateChecker`  
  - Main workflow: loads or builds the software list, handles user interaction, performs web checks, compares versions, and rewrites `updateList.txt`.[11]
- `debugLog`  
  - Helper for colored console output.  
  - If color is `"Red"`, prefixes the message with a timestamp and appends it to `C:\temp\debug.txt` before writing to the console. Otherwise, only writes to console.[13]

## Known limitations

- Version detection depends on finding a simple `version` string followed by digits in the page content; complex or script-driven pages may not be parsed correctly.[12]
- `Out-ConsoleGridView` requires a compatible host and may not work in headless or minimal environments.[13]
- Designed for a curated list of applications and URLs; it does not integrate with Windows Update or package managers.[15]
