pub mod commands {
    use std::process::Command;
    use std::fs::read_dir;

    #[derive(Debug)]
    pub enum CmdErr {
        Internal  = 0,
        Collision = 1,
        BuildErr  = 2,
        Killed    = 3,
    }

    pub fn new_target(target: &str, maybe_base: Option<&str>) -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/new_target.sh")
            .arg(target)
            .arg(match maybe_base {
                Some(base) => base,
                None => "",
            })
            .status();

        match attempt {
            Err(_) => Err(CmdErr::Internal),
            Ok (ret) => {
                match ret.code().unwrap() {
                    0 => Ok(()),
                    1 => Err(CmdErr::Collision), // Target already exists
                    2 => Err(CmdErr::BuildErr),  // Base target not found
                    _ => Err(CmdErr::Internal),
                }
            }
        }
    }

    pub fn update_buildroot() -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/update.sh")
            .status();

        match attempt {
            Err(_) => Err(CmdErr::Internal),
            Ok (code) => {
                match code.code().unwrap() {
                    0 => Ok(()),
                    1 => Err(CmdErr::Collision),
                    2 => Err(CmdErr::BuildErr),
                    _ => Err(CmdErr::Internal),
                }
            }
        }
    }

    /// This function builds the currently applied target
    pub fn build(target: &str, rebuild: bool) -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/build.sh")
            .arg(target)
            .arg( if rebuild { "true" }
                  else { "false" })
            .status();

        match attempt {
            Err(_) => Err(CmdErr::Internal),
            Ok (code) => {
                match code.code().unwrap() {
                    0 => Ok(()),
                    2 => Err(CmdErr::BuildErr),
                    _ => Err(CmdErr::Internal),
                }
            }
        }
    }

    pub fn list_targets() {
        let dirs: Vec<String> = read_dir("./targets")
            .expect("Couldn't read the contents of the `targets` directory")
            .map(|dir| {
                dir.unwrap().file_name().into_string().unwrap()
            })
            .collect();


        if dirs.len() == 0 {
            println!("No targets available");
            return
        }

        for dir in dirs {
            println!("{}", &dir);
        }

    }
}
