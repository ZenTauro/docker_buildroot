extern crate serde_derive;
extern crate serde_json;
#[macro_use]
extern crate clap;
extern crate git2;

extern crate self as lib;

use clap::{Arg, App, SubCommand};
use broot_docker::commands::{
    new_target,
    update_buildroot
};

fn main() {
    // Here we create the argument parsing structure
    // TODO change to macro for compile time struct creation
    let _matches = clap_app!(buildroot =>
                            (version: "0.1.0")
                            (author: "ZenTauro <zentauro@riseup.net>")
    );

    let app = App::new("build")
        .version("0.1.0")
        .author("ZenTauro <zentauro@riseup.net>")
        .about("Builds and/or configures a docker image")
        .after_help(concat!(
            "Copyright (C) 2018  zentauro\n",
            "This program comes with ABSOLUTELY NO WARRANTY; for details type ./broot-docker -h\n",
            "This is free software, and you are welcome to redistribute it\n",
            "under certain conditions;\n\n",
            "Type cat \"LICENSE.md\" for details.")
        )
        .subcommand(SubCommand::with_name("new")
                    .about("creates a new TARGET")
                    .arg(Arg::with_name("target")
                         .short("t")
                         .long("target")
                         .help("Builds the provided TARGET")
                         .takes_value(true)
                         .required(true)
                         .value_name("TARGET")
                    )
        )
        .subcommand(SubCommand::with_name("list")
                    .about("List available targets and exit")
        )
        .subcommand(SubCommand::with_name("build")
                    .about("Build the given TARGET")
                    .arg(Arg::with_name("target")
                         .index(1)
                         .help("Builds the provided TARGET")
                         .takes_value(true)
                         .required(true)
                         .value_name("TARGET")
                    )
                    .arg(Arg::with_name("rebuild")
                         .short("r")
                         .long("rebuild")
                         .help("Rebuild target")
                    )
                    .arg(Arg::with_name("edit")
                         .short("e")
                         .long("edit")
                         .help("Edits the given TARGET")
                    )
        )
        .arg(Arg::with_name("update")
             .short("u")
             .long("update")
             .help("Update buildroot and available targets")
        );

    let args = &app.get_matches();

    // Before matching against the arguments, we detect the
    // update flag to pass it around if needed
    let need_update = args.is_present("update");
    if  need_update {
        println!("Updating");
        match update_buildroot() {
            Ok (_) => (),
            Err(e) => println!("{:?}", e),
        };
    }

    // After obtaining the matches we map the args to the
    // corresponding subcommands
    match args.subcommand() {
        ("new", Some(args)) => {
            let res = new_target(
                &args.value_of("target")
                    .expect("Something went wrong obtaining the target")
            );
            match res {
                Err(e) => println!("{:?}", e),
                Ok (_) => (),
            }
        } ,
        ("list",  Some(_args)) => unimplemented!(),
        ("build", Some(_args)) => unimplemented!(),
        _ => {
            println!("Plese type \"broot-docker help\" to see how to use it");
        },
    };
}
