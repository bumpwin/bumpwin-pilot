module counter::tle_counter;

use sui::bcs;
use sui::clock::Clock;

const ENoAccess: u64 = 0;

public struct Counter has key, store {
    id: UID,
    value: u64,
}

public entry fun share_counter(ctx: &mut TxContext) {
    let counter = Counter {
        id: object::new(ctx),
        value: 0,
    };
    transfer::public_share_object(counter);
}

public entry fun increment(self: &mut Counter): u64 {
    self.value = self.value + 1;
    self.value
}

public entry fun add(self: &mut Counter, amount: u64): u64 {
    self.value = self.value + amount;
    self.value
}

public entry fun seal_approve(encoded_data: vector<u8>, clock: &Clock) {
    let mut decoder = bcs::new(encoded_data);
    let time_to_reveal = decoder.peel_u64();
    let leftovers = decoder.into_remainder_bytes();
    assert!(clock.timestamp_ms() >= time_to_reveal, ENoAccess);
    assert!(leftovers.length() == 0, ENoAccess);
}
