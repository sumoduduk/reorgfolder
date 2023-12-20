#![allow(unused_imports)]
mod move_file;

use clap::Parser;
use eyre::eyre;
use move_file::move_file;
use std::env;
use std::fs::{self, create_dir_all, DirEntry, File};
use std::io::{self, Read, Write};
use std::path::Path;

#[derive(Parser, Debug)]
#[command(
    name = "reorgfolder",
    about = "utility tool for reorganizing folders",
    author,
    version = "0.1.0"
)]
struct Command {
    #[arg(short = 'p', help = "path directory of target folder")]
    path: String,

    #[arg(
        short = 'o',
        long = "optional-folder",
        help = "(optional) optional folder will be created if not exist in the target folder as parent"
    )]
    optional_folder: Option<String>,
}

fn main() -> eyre::Result<()> {
    let args = Command::parse();

    let mut target_path = Path::new(&args.path).to_path_buf();
    let origin_path = target_path.clone();

    let file_names = fs::read_dir(&target_path).map_err(|e| eyre!("can't read folder : {}", e))?;

    if let Some(parent_folder) = args.optional_folder {
        let parent_path = target_path.join(&parent_folder).to_path_buf();
        target_path = parent_path;
    }

    println!("path : {:#?}", &target_path);

    for entry in file_names {
        let path = entry?.path();
        println!("filename {:#?}", &path);

        if path.is_dir() {
            continue;
        }

        let extension = path.extension();

        let extn_name = extension.and_then(|extn| extn.to_str());

        let Some(is_file) = extn_name else {
            continue;
        };

        let out_folder = target_path.join(is_file);

        create_folder(&out_folder)?;
        move_file(&origin_path, &out_folder, get_filename(&path)?)?
    }
    println!("finish");
    Ok(())
}

fn get_filename(path: &Path) -> eyre::Result<&str> {
    let file_name = path
        .file_name()
        .ok_or_else(|| eyre!("not a filename"))?
        .to_str()
        .ok_or_else(|| eyre!("cant get to string"))?;

    Ok(file_name)
}

fn create_folder(path: &Path) -> eyre::Result<()> {
    if !path.exists() {
        create_dir_all(path)?
    }
    Ok(())
}

