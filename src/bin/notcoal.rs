extern crate notcoal;

extern crate dirs;
extern crate ini;
extern crate structopt;

use notcoal::*;
use std::path::PathBuf;
use ini::Ini;
use structopt::StructOpt;
use std::process;

#[derive(StructOpt, Debug)]
#[structopt(name = "notcoal", about = "notmuch filters, not made from coal.")]
struct Opt {
    #[structopt(short = "c", long = "config", parse(from_os_str))]
    /// [default: ~/.notmuch-config]
    config: Option<PathBuf>,
    #[structopt(short = "f", long = "filters", parse(from_os_str))]
    /// [default: ~/$notmuchdb/.notmuch/hooks/notcoal-rules.json]
    filters: Option<PathBuf>,
    #[structopt(short = "t", long = "tag", default_value = "new")]
    tag: String
}

pub fn get_db_path(config: &Option<PathBuf>) -> PathBuf {
    let mut p: PathBuf;
    let config = match config {
        Some(p) => p,
        None => {
            p = dirs::home_dir().unwrap();
            p.push(".notmuch-config");
            &p
        }
    };
    let db = Ini::load_from_file(config).unwrap();
    PathBuf::from(db.get_from(Some("database"), "path").unwrap())
}

pub fn get_filters(path: &Option<PathBuf>, db_path: &PathBuf) -> Vec<Filter> {
    let mut p: PathBuf;
    let filter_path = match path {
        Some(p) => p,
        None => {
            p = db_path.clone();
            p.push(".notmuch/hooks/notcoal-rules.json");
            &p
        }
    };
    match filters_from_file(filter_path) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("{:?}", e);
            process::exit(1);
        }
    }
}

fn main() {
    let opt = Opt::from_args();
    let db_path = get_db_path(&opt.config);
    let filters = get_filters(&opt.filters, &db_path);
    match filter_with_path(get_db_path(&None), &opt.tag, &filters) {
        Ok(_) => {
            println!("Yay you filtered your new messages");
        }
        Err(e) => {
            println!("Oops: {:?}", e);
        }
    };
}
