pub mod commands {
    use std::process::{Command, ExitStatus};
    use std::fs::read_dir;

    #[derive(Debug)]
    /// Enum that describes the kind of errors that can happen during
    /// the execution of the different subcommands
    pub enum CmdErr {
        /// Returned in the case of an error executing the
        /// command or on unexpecter return value
        Internal(&'static str),  // Err or other return value
        /// Returned in the case that the match on `code.code()`
        /// returns None, which means that the process was killed
        Killed(&'static str),    // None,
        /// Returned when there is a name collision on the targets
        /// 
        /// Corresponds to return code 1
        Collision(&'static str), // 1,
        /// Returned when there was an error while constructing the
        /// target or on a specific action during the construction
        /// of an artifact
        /// 
        /// Corresponds to return code 2
        /// 
        /// ie.
        /// ```sh
        /// # This updates it and then updates it
        /// git submodule update --recursive --init || return 2
        /// ```
        BuildErr(&'static str),  // 2,
    }

    /// Error messages corresponding to the different fields of `CmdErr`
    struct ErrorMsgs {
        collision_1: &'static str,
        build_err_2: &'static str,
        internal: &'static str,
        killed: &'static str,
    }

    /// Abstraction ove the match of the `attempt` retrun value
    /// obtained while executing the command. This was done to
    /// provide an ergonomic way to deal with the different types
    /// of errors
    /// 
    /// The return values are documented in the `CmdErr` enum
    fn handle_script_return(attempt: Result<ExitStatus, std::io::Error>, error_msgs: &'static ErrorMsgs) -> Result<(), CmdErr> {
        match attempt {
            Err(_) => Err(CmdErr::Internal(error_msgs.internal)),
            Ok (code) => {
                match code.code() {
                    Some(c) => match c {
                        0 => Ok(()),
                        1 => Err(CmdErr::Collision(error_msgs.collision_1)),
                        2 => Err(CmdErr::BuildErr(error_msgs.build_err_2)),
                        _ => Err(CmdErr::Internal(error_msgs.internal)),
                    },
                    None => Err(CmdErr::Killed(error_msgs.killed)),
                }

            }
        }
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

        return handle_script_return(attempt,
            &ErrorMsgs {
                collision_1: "The target already exists",
                build_err_2: "The base target doesn't exist",
                internal: "Something bad happened while creating the target",
                killed: "The creation process was killed",
            }
        );
    }

    pub fn update_buildroot() -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/update.sh")
            .status();

        return handle_script_return(attempt,
            &ErrorMsgs {
                collision_1: "",
                build_err_2: "Failed to update the buildroot installation",
                internal: "Something bad happened while updating buildroot",
                killed: "The update process was killed",
            }
        );
    }

    /// This function builds the currently applied target
    pub fn build(target: &str, rebuild: bool) -> Result<(), CmdErr> {
        let attempt = Command::new("/bin/bash")
            .arg("./scripts/build.sh")
            .arg(target)
            .arg( if rebuild { "true" }
                  else { "false" })
            .status();

        return handle_script_return(attempt,
            &ErrorMsgs {
                collision_1: "DOCKER_ID_USER variable is not present",
                build_err_2: "Unable to apply the target specified, check its existence",
                internal: "Something went wrong",
                killed: "The build process was killed",
            }
        );
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
