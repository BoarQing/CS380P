//!
//! participant.rs
//! Implementation of 2PC participant
//!
extern crate ipc_channel;
extern crate log;
extern crate rand;
extern crate stderrlog;

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

use participant::ipc_channel::ipc::IpcReceiver as Receiver;
use participant::ipc_channel::ipc::IpcSender as Sender;
use participant::rand::prelude::*;

use message;
use message::ProtocolMessage;
use oplog;

///
/// ParticipantState
/// enum for Participant 2PC state machine
///
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ParticipantState {
    Quiescent,
    ReceivedP1,
    AwaitingGlobalDecision,
}

#[derive(Debug)]
pub struct Stat {
    success: u64,
    fail: u64,
    unknown: u64,
}
///
/// Participant
/// Structure for maintaining per-participant state and communication/synchronization objects to/from coordinator
///
#[derive(Debug)]
pub struct Participant {
    id_str: String,
    state: ParticipantState,
    log: oplog::OpLog,
    running: Arc<AtomicBool>,
    send_success_prob: f64,
    operation_success_prob: f64,
    sender: Sender<ProtocolMessage>,
    receiver: Receiver<ProtocolMessage>,
    msg: Vec<ProtocolMessage>,
    stat: Stat,
}

///
/// Participant
/// Implementation of participant for the 2PC protocol
/// Required:
/// 1. new -- Constructor
/// 2. pub fn report_status -- Reports number of committed/aborted/unknown for each participant
/// 3. pub fn protocol() -- Implements participant side protocol for 2PC
///
impl Participant {
    ///
    /// new()
    ///
    /// Return a new participant, ready to run the 2PC protocol with the coordinator.
    ///
    /// HINT: You may want to pass some channels or other communication
    ///       objects that enable coordinator->participant and participant->coordinator
    ///       messaging to this constructor.
    /// HINT: You may want to pass some global flags that indicate whether
    ///       the protocol is still running to this constructor. There are other
    ///       ways to communicate this, of course.
    ///
    pub fn new(
        id_str: String,
        log_path: String,
        r: Arc<AtomicBool>,
        send_success_prob: f64,
        operation_success_prob: f64,
        sender: Sender<ProtocolMessage>,
        receiver: Receiver<ProtocolMessage>,
    ) -> Participant {
        Participant {
            id_str: id_str,
            state: ParticipantState::Quiescent,
            log: oplog::OpLog::new(log_path),
            running: r,
            send_success_prob: send_success_prob,
            operation_success_prob: operation_success_prob,
            sender: sender,
            receiver: receiver,
            msg: Vec::<ProtocolMessage>::new(),
            stat: Stat {
                success: 0,
                fail: 0,
                unknown: 0,
            },
        }
    }

    ///
    /// send()
    /// Send a protocol message to the coordinator. This can fail depending on
    /// the success probability. For testing purposes, make sure to not specify
    /// the -S flag so the default value of 1 is used for failproof sending.
    ///
    /// HINT: You will need to implement the actual sending
    ///
    pub fn send(&mut self, pm: ProtocolMessage) {
        let x: f64 = random();
        if x > self.send_success_prob {
            return;
        }
        self.log.append(
            pm.mtype,
            pm.txid.clone(),
            self.id_str.clone(),
            pm.opid.clone(),
        );
        self.sender.send(pm).unwrap();
    }

    ///
    /// perform_operation
    /// Perform the operation specified in the 2PC proposal,
    /// with some probability of success/failure determined by the
    /// command-line option success_probability.
    ///
    /// HINT: The code provided here is not complete--it provides some
    ///       tracing infrastructure and the probability logic.
    ///       Your implementation need not preserve the method signature
    ///       (it's ok to add parameters or return something other than
    ///       bool if it's more convenient for your design).
    ///
    pub fn perform_operation(&mut self) -> bool {
        trace!("{}::Performing operation", self.id_str.clone());
        let x: f64 = random();
        x <= self.operation_success_prob
    }

    ///
    /// report_status()
    /// Report the abort/commit/unknown status (aggregate) of all transaction
    /// requests made by this coordinator before exiting.
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

    ///
    /// wait_for_exit_signal(&mut self)
    /// Wait until the running flag is set by the CTRL-C handler
    ///
    pub fn wait_for_exit_signal(&mut self) -> bool {
        self.running.load(Ordering::Relaxed) == false
    }

    pub fn quiescent(&mut self, exit: &mut bool) {
        if let Ok(msg) = self.receiver.try_recv() {
            if msg.mtype == message::MessageType::CoordinatorPropose {
                self.state = ParticipantState::ReceivedP1;
                self.stat.unknown += 1;
                self.msg.clear();
                self.msg.push(msg);
            } else {
                *exit = true;
            }
        }
    }
    pub fn received_p1(&mut self) {
        let suc = self.perform_operation();
        let mut msg_type = message::MessageType::ParticipantVoteCommit;
        if suc == false {
            msg_type = message::MessageType::ParticipantVoteAbort;
        }
        let txid = self.msg[0].txid.clone();
        let opid = self.msg[0].opid;
        let pm = message::ProtocolMessage::generate(msg_type, txid, self.id_str.clone(), opid);
        self.send(pm);
        self.state = ParticipantState::AwaitingGlobalDecision;
    }

    pub fn awaiting_global_decision(&mut self) {
        if let Ok(msg) = self.receiver.try_recv() {
            self.log.append(
                msg.mtype,
                msg.txid.clone(),
                self.id_str.clone(),
                msg.opid.clone(),
            );
            self.stat.unknown -= 1;
            if msg.mtype == message::MessageType::CoordinatorCommit {
                self.stat.success += 1;
            } else {
                self.stat.fail += 1;
            }
            self.state = ParticipantState::Quiescent;
        }
    }

    ///
    /// protocol()
    /// Implements the participant side of the 2PC protocol
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
                ParticipantState::Quiescent => self.quiescent(&mut exit),
                ParticipantState::ReceivedP1 => self.received_p1(),
                ParticipantState::AwaitingGlobalDecision => self.awaiting_global_decision(),
            }
            if exit {
                break;
            }
        }
        self.report_status();
    }
}
