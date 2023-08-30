#![allow(unused_imports)]
mod move_file;

use eyre::eyre;
use move_file::move_file;
use std::env;
use std::fs::{self, create_dir_all, DirEntry, File};
use std::io::{self, Read, Write};
use std::path::Path;

fn main() -> eyre::Result<()> {
    // let mut args = env::args();
    // let arg = args.nth(0).expect("add folder name");

    let parent_path = Path::new(".");

    let file_names = fs::read_dir(parent_path).map_err(|e| eyre!("can't read folder : {}", e))?;

    for entry in file_names {
        let path = entry?.path();

        let extension = path.extension();

        match extension {
            Some(exten) => {
                let extn_name = exten
                    .to_str()
                    .ok_or_else(|| eyre!("failed to parse extension to string"))?;

                let out_folder = parent_path.join(extn_name);
                create_folder(&out_folder)?;
                move_file(&parent_path, &out_folder, get_filename(&path)?)?
            }
            None => println!("{} is a folder", get_filename(&path)?),
        };
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
