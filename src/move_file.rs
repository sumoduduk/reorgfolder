use std::{
    fs::File,
    io,
    path::{Path, PathBuf},
    time::{SystemTime, UNIX_EPOCH},
};

pub fn move_file(src_path: &Path, out_path: &Path, file_name: &str) -> eyre::Result<()> {
    let src_file = src_path.join(file_name);
    let mut out_file = out_path.join(file_name);

    get_available_filename(&mut out_file);

    let mut in_file = File::open(&src_file)?;
    let mut target = File::create(out_file)?;

    let size = io::copy(&mut in_file, &mut target)?;

    println!("move {file_name} success, file size = {size}");
    trash::delete(src_file)?;

    Ok(())
}

fn get_available_filename(filename: &mut PathBuf) {
    while filename.exists() {
        let name_file = filename.file_stem().unwrap().to_string_lossy();

        let ext = filename.extension().unwrap().to_string_lossy();

        let new_name = if name_file.ends_with(')') {
            let index_split = name_file.rfind('(').unwrap_or(name_file.len());
            let (prefix, suffix) = name_file.split_at(index_split);

            let new_suffix = match suffix
                .trim_start_matches('(')
                .trim_end_matches(')')
                .parse::<u32>()
            {
                Ok(num) => (num + 1).to_string(),
                Err(_) => "1".to_string(),
            };

            format!("{}({})", prefix, new_suffix)
        } else {
            format!("{name_file}(1)")
        };

        let new_filename = format!("{new_name}.{ext}",);
        filename.set_file_name(new_filename);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempdir::TempDir;

    #[test]
    fn test_avail() {
        let temp_dir = TempDir::new("test_reorg").unwrap();
        let filename = temp_dir.path().join("test.txt");
        let mut filename_target = filename.to_owned();

        File::create(&filename).unwrap();

        get_available_filename(&mut filename_target);
        let expect_name = temp_dir.path().join("test(1).txt");

        assert_eq!(expect_name, filename_target);
    }

    #[test]
    fn test_avail_2() {
        let temp_dir = TempDir::new("test_reorg").unwrap();

        let filename = temp_dir.path().join("file.txt");
        let filename_1 = temp_dir.path().join("file(1).txt");
        let filename_2 = temp_dir.path().join("file(2).txt");
        let filename_3 = temp_dir.path().join("file(3).txt");

        let mut filename_target = filename.to_owned();

        File::create(&filename).unwrap();
        File::create(filename_1).unwrap();
        File::create(filename_2).unwrap();
        File::create(filename_3).unwrap();

        get_available_filename(&mut filename_target);
        let expect_name = temp_dir.path().join("file(4).txt");

        assert_eq!(expect_name, filename_target);
    }

    #[test]
    fn test_avail_3() {
        let mut filename = PathBuf::from("assets/nonexist.txt");

        get_available_filename(&mut filename);
        let expect_name = PathBuf::from("assets/nonexist.txt");

        assert_eq!(expect_name, filename);
    }
}
