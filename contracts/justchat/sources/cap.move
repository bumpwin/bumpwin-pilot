module justchat::cap;

public struct MessageFeeCap has key, store {
    id: UID,
    message_fee: u64,
    recipient: address,
}

public struct AdminCap has key, store {
    id: UID,
}

fun init(ctx: &mut TxContext) {
    let config = MessageFeeCap {
        id: object::new(ctx),
        message_fee: 1_000, // 1_000 MIST = 0.000_001 SUI
        recipient: ctx.sender(),
    };
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };

    transfer::public_transfer(admin_cap, ctx.sender());
    transfer::public_share_object(config);
}

public fun message_fee(cap: &MessageFeeCap): u64 {
    cap.message_fee
}

public fun recipient(cap: &MessageFeeCap): address {
    cap.recipient
}

public fun set_message_fee(
    _: &mut AdminCap,
    config: &mut MessageFeeCap,
    new_fee: u64,
) {
    config.message_fee = new_fee;
}

public fun set_recipient(
    _: &mut AdminCap,
    config: &mut MessageFeeCap,
    new_recipient: address,
) {
    config.recipient = new_recipient;
}
