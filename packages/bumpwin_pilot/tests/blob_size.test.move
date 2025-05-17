module bumpwin_pilot::blob_size_test;

use bumpwin_pilot::outcome_share::OutcomeShare;
use mockcoins::pink::PINK;
use std::ascii;
use std::debug;
use std::type_name;
use sui::bcs;
use sui::vec_map;

public fun get_serialized_size<T>(value: &T): u64 {
    let bytes = bcs::to_bytes(value);
    let size = bytes.length();
    debug::print(&size);
    size
}

#[test]
public fun test_blob_size() {
    let mut map = vec_map::empty<ascii::String, u64>();

    let key = type_name::get<PINK>().into_string();
    map.insert(key, 100);

    get_serialized_size(&map);
}
