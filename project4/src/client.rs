//!
//! client.rs
//! Implementation of 2PC client
//!
extern crate ipc_channel;
extern crate log;
extern crate stderrlog;

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

use client::ipc_channel::ipc::IpcReceiver as Receiver;
use client::ipc_channel::ipc::IpcSender as Sender;

use message;
use message::MessageType;
use message::ProtocolMessage;

#[derive(Debug)]
pub struct Stat {
    success: u64,
    fail: u64,
    unknown: u64,
}

// Client state and primitives for communicating with the coordinator
#[derive(Debug)]
pub struct Client {
    pub id_str: String,
    pub running: Arc<AtomicBool>,
    pub num_requests: u32,
    pub sender: Sender<ProtocolMessage>,
    pub receiver: Receiver<ProtocolMessage>,
    pub state: ClientState,
    pub stat: Stat,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ClientState {
    SendingJob,
    WaitForJobResult,
    JobDone,
    WaitForDoneResult,
    Finish,
}

///
/// Client Implementation
/// Required:
/// 1. new -- constructor
/// 2. pub fn report_status -- Reports number of committed/aborted/unknown
/// 3. pub fn protocol(&mut self, n_requests: i32) -- Implements client side protocol
///
impl Client {
    ///
    /// new()
    ///
    /// Constructs and returns a new client, ready to run the 2PC protocol
    /// with the coordinator.
    ///
    /// HINT: You may want to pass some channels or other communication
    ///       objects that enable coordinator->client and client->coordinator
    ///       messaging to this constructor.
    /// HINT: You may want to pass some global flags that indicate whether
    ///       the protocol is still running to this constructor
    ///
    pub fn new(
        id_str: String,
        running: Arc<AtomicBool>,
        sender: Sender<ProtocolMessage>,
        receiver: Receiver<ProtocolMessage>,
    ) -> Client {
        Client {
            id_str: id_str,
            running: running,
            num_requests: 0,
            sender: sender,
            receiver: receiver,
            state: ClientState::SendingJob,
            stat: Stat {
                success: 0,
                fail: 0,
                unknown: 0,
            },
        }
    }

    ///
    /// wait_for_exit_signal(&mut self)
    /// Wait until the running flag is set by the CTRL-C handler
    ///
    pub fn wait_for_exit_signal(&mut self) -> bool {
        self.running.load(Ordering::Relaxed) == false
    }

    ///
    /// send_next_operation(&mut self)
    /// Send the next operation to the coordinator
    ///
    pub fn send_next_operation(&mut self) {
        // Create a new request with a unique TXID.
        self.num_requests = self.num_requests + 1;
        let txid = format!("{}_op_{}", self.id_str.clone(), self.num_requests);
        let pm = message::ProtocolMessage::generate(
            message::MessageType::ClientRequest,
            txid.clone(),
            self.id_str.clone(),
            self.num_requests,
        );
        info!(
            "{}::Sending operation #{}",
            self.id_str.clone(),
            self.num_requests
        );

        let _ = self.sender.send(pm);

        trace!(
            "{}::Sent operation #{}",
            self.id_str.clone(),
            self.num_requests
        );
    }

    pub fn send_exit_msg(&mut self) {
        let pm = message::ProtocolMessage::generate(
            message::MessageType::CoordinatorExit,
            String::from(""),
            self.id_str.clone(),
            0,
        );
        let _ = self.sender.send(pm);
    }
    ///
    /// report_status()
    /// Report the abort/commit/unknown status (aggregate) of all transaction
    /// requests made by this client before exiting.
    ///
    pub fn report_status(&mut self) {
        println!(
            "{:16}:\tCommitted: {:6}\tAborted: {:6}\tUnknown: {:6}",
            self.id_str.clone(),
            self.stat.success,
            self.stat.fail,
            self.stat.unknown
        );
    }

    pub fn sending_job(&mut self) {
        self.send_next_operation();
        self.stat.unknown += 1;
        self.state = ClientState::WaitForJobResult;
    }
    pub fn recv_result(&mut self, n_requests: u32) {
        if let Ok(msg) = self.receiver.try_recv() {
            info!("{}::Receiving Coordinator Result", self.id_str.clone());
            self.stat.unknown -= 1;
            if msg.mtype == MessageType::ClientResultCommit {
                self.stat.success += 1;
            } else {
                self.stat.fail += 1;
            }
            if self.num_requests != n_requests {
                self.state = ClientState::SendingJob;
            } else {
                self.state = ClientState::JobDone;
            }
        }
    }
    pub fn job_done(&mut self) {
        self.send_exit_msg();
        self.state = ClientState::WaitForDoneResult;
    }
    pub fn wait_for_done_result(&mut self) {
        if let Ok(_) = self.receiver.try_recv() {
            self.state = ClientState::Finish;
        }
    }
    ///
    /// protocol()
    /// Implements the client side of the 2PC protocol
    /// HINT: if the simulation ends early, don't keep issuing requests!
    /// HINT: if you've issued all your requests, wait for some kind of
    ///       exit signal before returning from the protocol method!
    ///
    pub fn protocol(&mut self, n_requests: u32) {
        if n_requests == 0 {
            self.state = ClientState::JobDone;
        }
        loop {
            let exit = self.wait_for_exit_signal();
            if exit {
                break;
            }
            match self.state {
                ClientState::SendingJob => self.sending_job(),
                ClientState::WaitForJobResult => self.recv_result(n_requests),
                ClientState::JobDone => self.job_done(),
                ClientState::WaitForDoneResult => self.wait_for_done_result(),
                ClientState::Finish => break,
            }
        }
        self.report_status();
    }
}
