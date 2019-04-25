pub mod commands {
    use std::process::Command;

    #[derive(Debug)]
    pub enum CmdErr {
        Internal  = 0,
        Collision = 1,
        BuildErr  = 2,
        Killed    = 3,
    }

    pub fn new_target(target: &str) -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/new_target.sh")
            .arg(target)
            .status();

        match attempt {
            Err(_) => Err(CmdErr::Internal),
            Ok (ret) => match ret.code() {
                Some(code) => Ok(println!("Exited with status: {}", code)),
                None => Err(CmdErr::Killed),
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

    pub fn build() -> Result<(), CmdErr> {
        Ok(())
    }
    // pub fn list_targets
}
