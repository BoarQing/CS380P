//!
//! coordinator.rs
//! Implementation of 2PC coordinator
//!
extern crate ipc_channel;
extern crate log;
extern crate rand;
extern crate stderrlog;

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use coordinator::ipc_channel::ipc::channel;
use coordinator::ipc_channel::ipc::IpcReceiver as Receiver;
use coordinator::ipc_channel::ipc::IpcSender as Sender;

use message;
use message::ProtocolMessage;
use oplog;

/// CoordinatorState
/// States for 2PC state machine
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum CoordinatorState {
    Quiescent,
    ReceivedRequest,
    ProposalSent,
    SentGlobalDecision,
}

#[derive(Debug)]
pub struct Stat {
    success: u64,
    fail: u64,
    unknown: u64,
}

#[derive(Debug)]
pub struct Worker {
    sender: Sender<ProtocolMessage>,
    receiver: Receiver<ProtocolMessage>,
    active: bool,
}

#[derive(Debug)]
pub struct TranscationState {
    client_buffer: Vec<ProtocolMessage>,
    participant_buffer: Vec<ProtocolMessage>,
    idx: usize,
    transcation_id: u32,
    can_commit: bool,
    time: Instant,
}

impl TranscationState {
    pub fn new() -> TranscationState {
        TranscationState {
            client_buffer: Vec::new(),
            participant_buffer: Vec::new(),
            idx: 0,
            transcation_id: 0,
            can_commit: true,
            time: Instant::now(),
        }
    }
    pub fn set_client(&mut self, msg: ProtocolMessage, idx: usize) {
        self.idx = idx;
        self.client_buffer.clear();
        self.client_buffer.push(msg);
        self.participant_buffer.clear();
        self.transcation_id += 1;
        self.can_commit = true;
        self.time = Instant::now();
    }
    pub fn get_txid(&self) -> &String {
        return &self.client_buffer[0].txid;
    }
    pub fn get_opid(&self) -> u32 {
        return self.client_buffer[0].opid;
    }
    pub fn add_participant_msg(&mut self, msg: ProtocolMessage) {
        if msg.mtype == message::MessageType::ParticipantVoteAbort {
            self.can_commit = false;
        }
        self.participant_buffer.push(msg);
    }
    pub fn is_time_out(&mut self) -> bool {
        let duration = Duration::from_millis(100);
        if self.time.elapsed() >= duration {
            self.can_commit = false;
            return true;
        } else {
            return false;
        }
    }
}

/// Coordinator
/// Struct maintaining state for coordinator
#[derive(Debug)]
pub struct Coordinator {
    state: CoordinatorState,
    running: Arc<AtomicBool>,
    log: oplog::OpLog,
    client: Vec<Worker>,
    participant: Vec<Worker>,
    transaction_state: TranscationState,
    stat: Stat,
}

///
/// Coordinator
/// Implementation of coordinator functionality
/// Required:
/// 1. new -- Constructor
/// 2. protocol -- Implementation of coordinator side of protocol
/// 3. report_status -- Report of aggregate commit/abort/unknown stats on exit.
/// 4. participant_join -- What to do when a participant joins
/// 5. client_join -- What to do when a client joins
///
impl Coordinator {
    ///
    /// new()
    /// Initialize a new coordinator
    ///
    /// <params>
    ///     log_path: directory for log files --> create a new log there.
    ///     r: atomic bool --> still running?
    ///
    pub fn new(log_path: String, r: &Arc<AtomicBool>) -> Coordinator {
        Coordinator {
            state: CoordinatorState::Quiescent,
            log: oplog::OpLog::new(log_path),
            running: r.clone(),
            client: Vec::new(),
            participant: Vec::new(),
            stat: Stat {
                success: 0,
                fail: 0,
                unknown: 0,
            },
            transaction_state: TranscationState::new(),
        }
    }

    ///
    /// participant_join()
    /// Adds a new participant for the coordinator to keep track of
    ///
    /// HINT: Keep track of any channels involved!
    /// HINT: You may need to change the signature of this function
    ///
    pub fn participant_join(&mut self, ipc_path: String, sender: Sender<ProtocolMessage>) {
        assert!(self.state == CoordinatorState::Quiescent);
        let (tx, rx) = channel().unwrap();

        let connection = Sender::connect(ipc_path).unwrap();
        connection.send(tx.clone()).unwrap();

        let new_worker = Worker {
            sender: sender,
            receiver: rx,
            active: true,
        };
        self.participant.push(new_worker);
    }

    ///
    /// client_join()
    /// Adds a new client for the coordinator to keep track of
    ///
    /// HINT: Keep track of any channels involved!
    /// HINT: You may need to change the signature of this function
    ///
    pub fn client_join(&mut self, ipc_path: String, sender: Sender<ProtocolMessage>) {
        assert!(self.state == CoordinatorState::Quiescent);
        let (tx, rx) = channel().unwrap();

        let connection = Sender::connect(ipc_path).unwrap();
        connection.send(tx.clone()).unwrap();

        let new_worker = Worker {
            sender: sender,
            receiver: rx,
            active: true,
        };
        self.client.push(new_worker);
    }

    ///
    /// report_status()
    /// Report the abort/commit/unknown status (aggregate) of all transaction
    /// requests made by this coordinator before exiting.
    ///
    pub fn report_status(&mut self) {
        println!(
            "coordinator     :\tCommitted: {:6}\tAborted: {:6}\tUnknown: {:6}",
            self.stat.success, self.stat.fail, self.stat.unknown
        );
    }

    pub fn notify_paritcipant_to_exit(&mut self) {
        for p in self.participant.iter() {
            let pm = message::ProtocolMessage::generate(
                message::MessageType::CoordinatorExit,
                String::from(""),
                String::from("Coordinator"),
                0,
            );
            p.sender.send(pm).unwrap();
        }
    }
    pub fn handle_client_msg(&mut self, msg: ProtocolMessage, idx: usize) {
        if msg.mtype == message::MessageType::CoordinatorExit {
            self.client[idx].active = false;
            let pm = message::ProtocolMessage::generate(
                message::MessageType::CoordinatorExit,
                String::from(""),
                String::from("Coordinator"),
                0,
            );
            self.client[idx].sender.send(pm).unwrap();
        } else {
            self.transaction_state.set_client(msg, idx);
            self.state = CoordinatorState::ReceivedRequest;
            self.stat.unknown += 1;
        }
    }
    pub fn quiescent(&mut self, exit: &mut bool) {
        let mut finish_count = 0;
        for idx in 0..self.client.len() {
            if self.client[idx].active == false {
                finish_count += 1;
                continue;
            }
            if let Ok(msg) = self.client[idx].receiver.try_recv() {
                self.handle_client_msg(msg, idx);
                return;
            }
        }
        if finish_count == self.client.len() {
            self.notify_paritcipant_to_exit();
            *exit = true;
        }
    }
    pub fn received_request(&mut self) {
        let txid = &self.transaction_state.get_txid();
        let opid = self.transaction_state.get_opid();
        for idx in 0..self.participant.len() {
            let pm = message::ProtocolMessage::generate(
                message::MessageType::CoordinatorPropose,
                (*txid).clone(),
                String::from("Coordinator"),
                opid,
            );
            self.participant[idx].sender.send(pm).unwrap();
        }
        self.state = CoordinatorState::ProposalSent;
    }
    pub fn proposal_sent(&mut self) {
        for idx in 0..self.participant.len() {
            if let Ok(msg) = self.participant[idx].receiver.try_recv() {
                self.transaction_state.add_participant_msg(msg);
            }
        }
        if self.transaction_state.participant_buffer.len() == self.participant.len() {
            self.state = CoordinatorState::SentGlobalDecision;
        }
        if self.transaction_state.is_time_out() {
            self.state = CoordinatorState::SentGlobalDecision;
        }
    }
    pub fn sent_global_decision(&mut self) {
        self.stat.unknown -= 1;
        let mut participant_msg_type = message::MessageType::CoordinatorCommit;
        let mut client_msg_type = message::MessageType::ClientResultCommit;

        let txid = &self.transaction_state.get_txid();
        let opid = self.transaction_state.get_opid();

        if self.transaction_state.can_commit {
            self.stat.success += 1;
        } else {
            self.stat.fail += 1;
            participant_msg_type = message::MessageType::CoordinatorAbort;
            client_msg_type = message::MessageType::ClientResultAbort;
        }

        self.log.append(
            participant_msg_type,
            (*txid).clone(),
            String::from("Coordinator"),
            opid,
        );

        for idx in 0..self.participant.len() {
            let pm = message::ProtocolMessage::generate(
                participant_msg_type,
                (*txid).clone(),
                String::from("Coordinator"),
                opid,
            );
            self.participant[idx].sender.send(pm).unwrap();
        }
        let pm = message::ProtocolMessage::generate(
            client_msg_type,
            (*txid).clone(),
            String::from("Coordinator"),
            opid,
        );
        self.client[self.transaction_state.idx]
            .sender
            .send(pm)
            .unwrap();
        self.state = CoordinatorState::Quiescent;
    }
    pub fn wait_for_exit_signal(&mut self) -> bool {
        self.running.load(Ordering::Relaxed) == false
    }
    ///
    /// protocol()
    /// Implements the coordinator side of the 2PC protocol
    /// HINT: If the simulation ends early, don't keep handling requests!
    /// HINT: Wait for some kind of exit signal before returning from the protocol!
    ///
    pub fn protocol(&mut self) {
        loop {
            let mut exit = self.wait_for_exit_signal();
            if exit {
                break;
            }
            match self.state {
                CoordinatorState::Quiescent => self.quiescent(&mut exit),
                CoordinatorState::ReceivedRequest => self.received_request(),
                CoordinatorState::ProposalSent => self.proposal_sent(),
                CoordinatorState::SentGlobalDecision => self.sent_global_decision(),
            }
            if exit {
                break;
            }
        }
        self.report_status();
    }
}
