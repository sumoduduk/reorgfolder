# reorgfolder

`reorgfolder` is a blazingly fast and safe utility written in Rust for reorganizing folders by grouping files based on their extensions, copying the files to respective folders, and moving the original files to the trash/recycle bin. This tool aims to simplify and automate the process of organizing files on your system.

## Features

- Organize files by extension into separate folders.
- Only 400kb.
- Copy files to appropriate folders.
- Move the original files to the trash (on macOS) or recycle bin (on Windows).
- Fast and efficient implementation in Rust.
- Simple installation and usage.

## Installation

### Clone the repository:

```bash
git clone https://github.com/sumoduduk/reorgfolder.git
cd reorgfolder
```

### Build the program using Cargo:

```bash
cargo build --release
```

Add the built program to your PATH for easy access:

## macOS / Linux:

```bash
echo 'export PATH="$PATH:/path/to/reorgfolder/target/release"' >> ~/.bashrc
source ~/.bashrc
```

## Windows (PowerShell):

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\path\to\reorgfolder\target\release", "User")
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User")
```

## Usage

Navigate to the destination folder where you want to reorganize files.

Run the reorgfolder command:

```bash
reorgfolder
```

The utility will then categorize the files in the folder based on their extensions, copy them to their respective subfolders, and move the original files to the trash (macOS) or recycle bin (Windows).

## License

This project is licensed under the MIT License.

Enjoy using reorgfolder for a cleaner and more organized file system!
