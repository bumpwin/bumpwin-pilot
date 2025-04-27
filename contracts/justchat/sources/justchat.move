module justchat::messaging;

use sui::tx_context::TxContext;
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;
use sui::transfer::public_transfer;
use sui::event::emit;
use std::string::String;

public struct MessagingConfig has key, store {
    id: object::UID,
    message_fee: u64,
}

public struct Message has drop {
    recipient: address,
    text: String,
}

public struct MessageReceivedEvent has copy, drop, store {
    sender: address,
    recipient: address,
    text: String,
    amount: u64,
}

public fun new_config(
    message_fee: u64,
    ctx: &mut TxContext
): MessagingConfig {
    MessagingConfig {
        id: object::new(ctx),
        message_fee,
    }
}

public fun send_message(
    msg: Message,
    payment: Balance<SUI>,
    config: &MessagingConfig,
    ctx: &mut TxContext
): Coin<SUI> {
    let recipient = msg.recipient;
    let sender = ctx.sender();

    assert!(sender == recipient, 1);
    assert!(&payment.value() == config.message_fee, 0);

    emit(
        MessageReceivedEvent {
            sender,
            recipient,
            text: msg.text,
            amount: payment.value(),
        }
    );


    let mut to_pay = payment.into_coin(ctx);
    let to_keep = to_pay.split(config.message_fee, ctx);

    public_transfer(to_pay, recipient);

    to_keep
}
