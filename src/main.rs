use google_pubsub1::api::PullRequest;
use google_pubsub1::{
    oauth2::{
        authenticator::ApplicationDefaultCredentialsTypes,
        ApplicationDefaultCredentialsAuthenticator, ApplicationDefaultCredentialsFlowOpts,
    },
    Pubsub,
};
use std::default::Default;

async fn run() {
    let opts = ApplicationDefaultCredentialsFlowOpts::default();
    let authenticator = match ApplicationDefaultCredentialsAuthenticator::builder(opts).await {
        ApplicationDefaultCredentialsTypes::InstanceMetadata(auth) => auth
            .build()
            .await
            .expect("Unable to create instance metadata authenticator"),
        ApplicationDefaultCredentialsTypes::ServiceAccount(auth) => auth
            .build()
            .await
            .expect("Unable to create service account authenticator"),
    };

    println!("Got auth");

    let mut hub = Pubsub::new(
        hyper::Client::builder().build(
            hyper_rustls::HttpsConnectorBuilder::new()
                .with_native_roots()
                .https_only()
                .enable_http1()
                .enable_http2()
                .build(),
        ),
        authenticator,
    );

    println!("Got hub");

    let subscription = "projects/lukeshay/subscriptions/rust-cdc-subscription";

    let result = hub
        .projects()
        .subscriptions_pull(PullRequest::default(), &subscription)
        .doit()
        .await;

    println!("Got result");

    println!("{:?}", result);
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    run().await;

    Ok(())
}
