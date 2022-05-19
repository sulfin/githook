#[macro_use]
extern crate rocket;
use rocket::http::Status;
use rocket::serde::{json::Json, Deserialize};

use std::fs::File;
use std::io::prelude::*;

#[derive(Deserialize)]
struct GithubWebhookPayload<'r> {
    #[serde(rename = "ref")]
    _ref: &'r str,
    after: &'r str,
    repository: GithubWebhookRepository<'r>,
}

#[derive(Deserialize)]
struct GithubWebhookRepository<'r> {
    name: &'r str,
    full_name: &'r str,
}

#[post("/githook", format = "application/json", data = "<payload>")]
fn githook(payload: Json<GithubWebhookPayload<'_>>) -> Status {
    //println!("{}", payload._ref);
    if payload._ref == "refs/heads/main" || payload._ref == "refs/heads/master" {
        let file_base = String::from("updates/");
        let file_name = file_base + payload.repository.name;
        println!("Changement sur main !");
        let mut need_update = true;
        match File::open(&file_name) {
            Ok(mut file) => {
                let mut content = String::new();
                file.read_to_string(&mut content);
                if content == payload.after {
                    need_update = false;
                }
            }
            Err(_e) => {}
        }

        if need_update {
            println!("Update du fichier");
            let mut file = File::create(&file_name).expect("unable to create file");
            file.write(payload.after.as_bytes())
                .expect("unable to write");
        }
    } else {
        println!("On s'en fou !");
    }
    Status::Accepted
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![githook])
}
