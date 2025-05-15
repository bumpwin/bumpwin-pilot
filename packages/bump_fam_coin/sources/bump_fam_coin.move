module bump_fam_coin::bump_fam_coin;

use sui::coin;

const DECIMALS: u8 = 6; // Number of decimal places (1 coin = 10^6 base units)

public struct BUMP_FAM_COIN has drop {}


fun init(witness: BUMP_FAM_COIN, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<BUMP_FAM_COIN>(
        witness,
        DECIMALS,           // decimals
        b"TBD_SYMBOL",      // symbol
        b"TBD_NAME",        // name
        b"TBD_DESCRIPTION", // description
        option::none(),     // icon_url
        ctx
    );

    transfer::public_transfer(treasury_cap, ctx.sender());
    transfer::public_transfer(metadata, ctx.sender());
}


#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(BUMP_FAM_COIN {}, ctx);
}