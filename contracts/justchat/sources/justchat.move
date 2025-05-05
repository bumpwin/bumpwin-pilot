module justchat::messaging;

use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;
use std::string::String;

use justchat::cap;

/// Event emitted when a message is received
public struct MessageReceivedEvent has copy, drop, store {
    sender: address,
    recipient: address,
    text: String,
    amount: u64,
}


/// Send a message with payment
public fun send_message(
    cap: &cap::MessageFeeCap,
    text: String,
    mut payment: Coin<SUI>,
    ctx: &mut TxContext
): Coin<SUI> {
    assert!(payment.value() >= cap.message_fee(), 0);

    let to_keep = coin::split(&mut payment, cap.message_fee(), ctx);

    event::emit(
        MessageReceivedEvent {
            sender: ctx.sender(),
            recipient: cap.recipient(),
            text,
            amount: payment.value(),
        }
    );

    transfer::public_transfer(payment, cap.recipient());

    to_keep
}
