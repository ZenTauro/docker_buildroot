extern crate clap;
extern crate git2;

use clap::{Arg, App, SubCommand};

use std::fs;

fn show_gpl() {
    println!(
"Copyright (C) 2018  zentauro
This program comes with ABSOLUTELY NO WARRANTY; for details type ./build.sh -h
This is free software, and you are welcome to redistribute it
under certain conditions;

Type cat \"LICENSE.md\" for details."
    );
}

fn main() {
    let matches = App::new("build")
        .version("0.1.0")
        .author("ZenTauro <zentauro@riseup.net>")
        .about("Builds and/or configures a docker image")
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
        )
        .get_matches();

    println!("the structure {:?}", matches);
}