module vault_center::root;

public struct Root has key, store {
    id: UID,
    vault_list: vector<ID>,
}

fun init(ctx: &mut TxContext) {
    let root = Root {
        id: object::new(ctx),
        vault_list: vector[],
    };
    transfer::public_share_object(root);
}

public fun add_vault_id(self: &mut Root, vault_id: ID) {
    self.vault_list.push_back(vault_id);
}
