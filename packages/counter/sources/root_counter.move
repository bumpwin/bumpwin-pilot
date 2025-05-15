module counter::root_counter;

use sui::event;
use sui::object_table::{Self, ObjectTable};

public struct Counter has key, store {
    id: UID,
    value: u64,
}

public struct Root has key, store {
    id: UID,
    counters: ObjectTable<ID, Counter>,
}

public struct NewCounterEvent has copy, drop {
    id: ID,
}

public struct IncrementEvent has copy, drop {
    id: ID,
}

public entry fun share_root(ctx: &mut TxContext) {
    let root = Root {
        id: object::new(ctx),
        counters: object_table::new(ctx),
    };

    transfer::public_share_object(root);
}

public entry fun create_counter(self: &mut Root, ctx: &mut TxContext): ID {
    let counter = Counter {
        id: object::new(ctx),
        value: 0,
    };
    let id = counter.id.to_inner();
    self
        .counters
        .add(
            counter.id.to_inner(),
            counter,
        );
    id
}

public entry fun create_counter_with_event(self: &mut Root, ctx: &mut TxContext) {
    let id = self.create_counter(ctx);
    event::emit(NewCounterEvent {
        id,
    });
}

public fun borrow_mut_counter(self: &mut Root, id: ID): &mut Counter {
    self.counters.borrow_mut(id)
}

public entry fun increment(self: &mut Root, id: ID): ID {
    let counter = self.borrow_mut_counter(id);
    counter.value = counter.value + 1;
    counter.id.to_inner()
}

public entry fun increment_with_event(self: &mut Root, id: ID) {
    let id = self.increment(id);
    event::emit(IncrementEvent {
        id,
    });
}
