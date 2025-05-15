module justchat::messaging;

use justchat::cap;
use std::string::String;
use sui::coin::Coin;
use sui::event;
use sui::sui::SUI;

const EWrongAmount: u64 = 0;

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
    payment: Coin<SUI>,
    ctx: &mut TxContext,
) {
    assert!(payment.value() == cap.message_fee(), EWrongAmount);

    event::emit(MessageReceivedEvent {
        sender: ctx.sender(),
        recipient: cap.recipient(),
        text,
        amount: payment.value(),
    });

    transfer::public_transfer(payment, cap.recipient());
}
