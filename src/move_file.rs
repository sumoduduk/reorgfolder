use std::{
    fs::File,
    io,
    path::Path,
    time::{SystemTime, UNIX_EPOCH},
};

pub fn move_file(src_path: &Path, out_path: &Path, file_name: &str) -> eyre::Result<()> {
    let src_file = src_path.join(file_name);
    let clone = src_file.clone();
    let mut out_file = out_path.join(file_name);

    if out_file.exists() {
        let rand = get_time();
        let new_file_name = format!("{rand}-{file_name}");
        out_file = out_path.join(new_file_name);
    }

    let mut in_file = File::open(src_file)?;
    let mut target = File::create(out_file)?;

    let size = io::copy(&mut in_file, &mut target)?;

    println!("move {file_name} success, file size = {size}");
    trash::delete(clone)?;

    Ok(())
}

fn get_time() -> u16 {
    let seed = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let random_number: u16 = (seed % (u16::MAX as u64 + 1)) as u16;
    random_number
}
