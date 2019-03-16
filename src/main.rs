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
        .arg(Arg::with_name("target")
             .short("t")
             .long("target")
             .help("Builds the provided target")
             .takes_value(true)
             .required(true)
             .value_name("TARGET")
        )
        .get_matches();

    let target = matches.value_of("target")
        .expect("Something went terribly wrong");

    println!("The given target is {}", target);
}
