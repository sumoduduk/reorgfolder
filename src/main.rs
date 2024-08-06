#![allow(unused_imports)]
mod move_file;

use clap::Parser;
use eyre::eyre;
use move_file::move_file;
use std::fs::{self, create_dir_all, DirEntry, File};
use std::io::{self, Read, Write};
use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::{env, thread};

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

    let mut target_path = PathBuf::from(&args.path);
    let origin_path = target_path.clone();

    let file_names = fs::read_dir(&target_path).map_err(|e| eyre!("can't read folder : {}", e))?;

    if let Some(parent_folder) = args.optional_folder {
        target_path.push(parent_folder);
    }

    println!("path : {:#?}", &target_path);

    let mut handlers = Vec::new();

    let arc_target_path = Arc::new(target_path);
    let arc_origin = Arc::new(origin_path);

    for entry in file_names {
        let target_clone = Arc::clone(&arc_target_path);

        let target_origin = Arc::clone(&arc_origin);

        let path = entry?.path();
        let handler = thread::spawn(move || {
            println!("filename {:#?}", &path);

            if path.is_dir() {
                return;
            }

            let extension = path.extension();

            let extn_name = extension.and_then(|extn| extn.to_str());

            let Some(is_file) = extn_name else {
                return;
            };

            let out_folder = target_clone.join(is_file);

            match create_folder(&out_folder) {
                Ok(_) => {
                    if let Ok(name_file) = get_filename(&path) {
                        let _ = move_file(&target_origin, &out_folder, name_file);
                    }
                }

                Err(err) => {
                    println!("{err}")
                }
            }
        });

        handlers.push(handler);
    }

    for handler in handlers {
        match handler.join() {
            Ok(_) => {}
            Err(err) => {
                dbg!(err);
            }
        }
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
