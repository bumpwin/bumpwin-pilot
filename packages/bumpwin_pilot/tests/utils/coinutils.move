#[test_only]
module bumpwin_pilot::coinutils;

use sui::coin::TreasuryCap;
use sui::test_scenario::{Self as test, ctx};

public fun mint_to<T>(amount: u64, signer: address, test: &mut test::Scenario) {
    test.next_tx(signer);
    {
        let mut cap = test.take_shared<TreasuryCap<T>>();
        let coin = cap.mint(amount, test.ctx());
        transfer::public_transfer(coin, @alice);
        test::return_shared(cap);
    };
}
