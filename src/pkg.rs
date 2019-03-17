use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Package {
    name:    String,
    version: String,
    authors: Vec<Author>,
    license: String,
    image:   Option<String>,
}

#[derive(Serialize, Deserialize)]
pub struct Author {
    name: String,
    info: Option<String>,
}
