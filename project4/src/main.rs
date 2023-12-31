#[macro_use]
extern crate log;
extern crate clap;
extern crate ctrlc;
extern crate ipc_channel;
extern crate stderrlog;
use ipc_channel::ipc::channel;
use ipc_channel::ipc::IpcOneShotServer;
use ipc_channel::ipc::IpcReceiver as Receiver;
use ipc_channel::ipc::IpcSender as Sender;
use std::env;
use std::fs;
use std::process::{Child, Command};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
pub mod checker;
pub mod client;
pub mod coordinator;
pub mod message;
pub mod oplog;
pub mod participant;
pub mod tpcoptions;
use message::ProtocolMessage;
use std::time::{Instant, Duration};

///
/// pub fn spawn_child_and_connect(child_opts: &mut tpcoptions::TPCOptions) -> (std::process::Child, Sender<ProtocolMessage>, Receiver<ProtocolMessage>)
///
///     child_opts: CLI options for child process
///
/// 1. Set up IPC
/// 2. Spawn a child process using the child CLI options
/// 3. Do any required communication to set up the parent / child communication channels
/// 4. Return the child process handle and the communication channels for the parent
///
/// HINT: You can change the signature of the function if necessary
///
fn spawn_child_and_connect(
    child_opts: &mut tpcoptions::TPCOptions,
) -> (Child, Sender<ProtocolMessage>, String) {
    let (server, server_name) =
        IpcOneShotServer::<(Sender<ProtocolMessage>, String)>::new().unwrap();
    child_opts.ipc_path = server_name;
    let child = Command::new(env::current_exe().unwrap())
        .args(child_opts.as_vec())
        .spawn()
        .expect("Failed to execute child process");

    let (_, (sender, server_name)) = server.accept().unwrap();
    (child, sender, server_name)
}

///
/// pub fn connect_to_coordinator(opts: &tpcoptions::TPCOptions) -> (Sender<ProtocolMessage>, Receiver<ProtocolMessage>)
///
///     opts: CLI options for this process
///
/// 1. Connect to the parent via IPC
/// 2. Do any required communication to set up the parent / child communication channels
/// 3. Return the communication channels for the child
///
/// HINT: You can change the signature of the function if necessasry
///
fn connect_to_coordinator(
    opts: &tpcoptions::TPCOptions,
) -> (Sender<ProtocolMessage>, Receiver<ProtocolMessage>) {
    let ipc_path = opts.ipc_path.clone();
    let connection = Sender::connect(ipc_path).unwrap();
    let (server, server_name) = IpcOneShotServer::<Sender<ProtocolMessage>>::new().unwrap();
    let (tx, rx) = channel().unwrap();
    connection.send((tx, server_name)).unwrap();
    let (_, sender) = server.accept().unwrap();
    (sender, rx)
}

///
/// pub fn run(opts: &tpcoptions:TPCOptions, running: Arc<AtomicBool>)
///     opts: An options structure containing the CLI arguments
///     running: An atomically reference counted (ARC) AtomicBool(ean) that is
///         set to be false whenever Ctrl+C is pressed
///
/// 1. Creates a new coordinator
/// 2. Spawns and connects to new clients processes and then registers them with
///    the coordinator
/// 3. Spawns and connects to new participant processes and then registers them
///    with the coordinator
/// 4. Starts the coordinator protocol
/// 5. Wait until the children finish execution
///
fn run(opts: &tpcoptions::TPCOptions, running: Arc<AtomicBool>) {
    let coord_log_path = format!("{}//{}", opts.log_path, "coordinator.log");
    let mut coordinator = coordinator::Coordinator::new(coord_log_path, &running);

    let mut client_opts = opts.clone();
    client_opts.mode = "client".to_string();
    let mut children = Vec::new();
    for idx in 0..opts.num_clients {
        client_opts.num = idx;
        let (child, tx, server_name) = spawn_child_and_connect(&mut client_opts);
        coordinator.client_join(server_name, tx);
        children.push(child);
    }

    let mut participant_opts = opts.clone();
    participant_opts.mode = "participant".to_string();
    for idx in 0..opts.num_participants {
        participant_opts.num = idx;
        spawn_child_and_connect(&mut participant_opts);
        let (child, tx, server_name) = spawn_child_and_connect(&mut participant_opts);
        coordinator.participant_join(server_name, tx);
        children.push(child);
    }
    let start_time = Instant::now();
    coordinator.protocol();

    for mut child in children {
        child.wait().unwrap();
    }
    let finish_time = Instant::now();
    let elapsed_time = finish_time - start_time;
    println!("Elapsed Time: {:?}", elapsed_time.as_millis());
}

///
/// pub fn run_client(opts: &tpcoptions:TPCOptions, running: Arc<AtomicBool>)
///     opts: An options structure containing the CLI arguments
///     running: An atomically reference counted (ARC) AtomicBool(ean) that is
///         set to be false whenever Ctrl+C is pressed
///
/// 1. Connects to the coordinator to get tx/rx
/// 2. Constructs a new client
/// 3. Starts the client protocol
///
fn run_client(opts: &tpcoptions::TPCOptions, running: Arc<AtomicBool>) {
    let (tx, rx) = connect_to_coordinator(opts);

    let client_id_str = format!("client_{}", opts.num);
    let mut client = client::Client::new(client_id_str, running, tx, rx);
    client.protocol(opts.num_requests);
}

///
/// pub fn run_participant(opts: &tpcoptions:TPCOptions, running: Arc<AtomicBool>)
///     opts: An options structure containing the CLI arguments
///     running: An atomically reference counted (ARC) AtomicBool(ean) that is
///         set to be false whenever Ctrl+C is pressed
///
/// 1. Connects to the coordinator to get tx/rx
/// 2. Constructs a new participant
/// 3. Starts the participant protocol
///
fn run_participant(opts: &tpcoptions::TPCOptions, running: Arc<AtomicBool>) {
    let (tx, rx) = connect_to_coordinator(opts);

    let participant_id_str = format!("participant_{}", opts.num);
    let participant_log_path = format!("{}//{}.log", opts.log_path, participant_id_str);
    let mut participant = participant::Participant::new(
        participant_id_str,
        participant_log_path,
        running,
        opts.send_success_probability,
        opts.operation_success_probability,
        tx,
        rx,
    );
    participant.protocol();
}

fn main() {
    // Parse CLI arguments
    let opts = tpcoptions::TPCOptions::new();
    // Set-up logging and create OpLog path if necessary
    stderrlog::new()
        .module(module_path!())
        .quiet(false)
        .timestamp(stderrlog::Timestamp::Millisecond)
        .verbosity(opts.verbosity)
        .init()
        .unwrap();
    match fs::create_dir_all(opts.log_path.clone()) {
        Err(e) => error!(
            "Failed to create log_path: \"{:?}\". Error \"{:?}\"",
            opts.log_path, e
        ),
        _ => (),
    }

    // Set-up Ctrl-C / SIGINT handler
    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();
    let m = opts.mode.clone();
    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
        if m == "run" {
            print!("\n");
        }
    })
    .expect("Error setting signal handler!");

    // Execute main logic
    match opts.mode.as_ref() {
        "run" => run(&opts, running),
        "client" => run_client(&opts, running),
        "participant" => run_participant(&opts, running),
        "check" => checker::check_last_run(
            opts.num_clients,
            opts.num_requests,
            opts.num_participants,
            &opts.log_path,
        ),
        _ => panic!("Unknown mode"),
    }
}
