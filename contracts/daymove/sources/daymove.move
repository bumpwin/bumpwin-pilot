module daymove::daymove;

use daymove::constants;
use daymove::helpers;
use daymove::utc_offset::{Self, UtcOffset};

// OffsetDateTime structure that stores timestamp_ms and offset
public struct OffsetDateTime has copy, drop {
    timestamp_ms: u64,
    offset: UtcOffset,
}

// =======================================
// Constructors
// =======================================

// Create a new OffsetDateTime from components with UTC timezone
public fun new_utc(y: u16, m: u8, d: u8, h: u8, min: u8, s: u8): OffsetDateTime {
    let timestamp_ms = helpers::components_to_timestamp(y, m, d, h, min, s, &utc_offset::utc());

    OffsetDateTime {
        timestamp_ms,
        offset: utc_offset::utc(),
    }
}

// Creates an OffsetDateTime from a UTC timestamp in milliseconds
public fun from_timestamp_ms(timestamp_ms: u64): OffsetDateTime {
    OffsetDateTime {
        timestamp_ms,
        offset: utc_offset::utc(),
    }
}

// =======================================
// Getters/Converters - Using method style with self
// =======================================

// Get component methods
public fun year(self: &OffsetDateTime): u16 {
    let (y, _, _, _, _, _, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    y
}

public fun month(self: &OffsetDateTime): u8 {
    let (_, m, _, _, _, _, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    m
}

public fun day(self: &OffsetDateTime): u8 {
    let (_, _, d, _, _, _, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    d
}

public fun hour(self: &OffsetDateTime): u8 {
    let (_, _, _, h, _, _, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    h
}

public fun minute(self: &OffsetDateTime): u8 {
    let (_, _, _, _, m, _, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    m
}

public fun second(self: &OffsetDateTime): u8 {
    let (_, _, _, _, _, s, _) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    s
}

// Method to get milliseconds part
public fun millisecond(self: &OffsetDateTime): u16 {
    let (_, _, _, _, _, _, ms) = helpers::decompose_timestamp(self.timestamp_ms, &self.offset);
    ms
}

// Extract UtcOffset from a OffsetDateTime
public fun offset(self: &OffsetDateTime): UtcOffset {
    self.offset
}

// Convert to timestamp in milliseconds
public fun to_timestamp_ms(self: &OffsetDateTime): u64 {
    self.timestamp_ms
}

// =======================================
// Time arithmetic methods - Using method style with self
// =======================================

// Add operations
public fun add_days(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    // Simply add days worth of milliseconds
    let new_timestamp = self.timestamp_ms + (delta * constants::ms_per_day());

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun add_hours(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let new_timestamp = self.timestamp_ms + (delta * constants::ms_per_hour());

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun add_minutes(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let new_timestamp = self.timestamp_ms + (delta * constants::ms_per_minute());

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun add_seconds(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let new_timestamp = self.timestamp_ms + (delta * constants::ms_per_second());

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun add_milliseconds(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let new_timestamp = self.timestamp_ms + delta;

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

// Subtract operations - with proper error handling
public fun sub_days(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let ms_delta = delta * constants::ms_per_day();
    let new_timestamp = helpers::try_sub(self.timestamp_ms, ms_delta).extract();

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun sub_hours(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let ms_delta = delta * constants::ms_per_hour();
    let new_timestamp = helpers::try_sub(self.timestamp_ms, ms_delta).extract();

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun sub_minutes(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let ms_delta = delta * constants::ms_per_minute();
    let new_timestamp = helpers::try_sub(self.timestamp_ms, ms_delta).extract();

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun sub_seconds(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let ms_delta = delta * constants::ms_per_second();
    let new_timestamp = helpers::try_sub(self.timestamp_ms, ms_delta).extract();

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

public fun sub_milliseconds(self: &OffsetDateTime, delta: u64): OffsetDateTime {
    let new_timestamp = helpers::try_sub(self.timestamp_ms, delta).extract();

    OffsetDateTime {
        timestamp_ms: new_timestamp,
        offset: self.offset,
    }
}

// =======================================
// Additional utility methods
// =======================================

// Change the offset of a OffsetDateTime without changing the actual moment in time
public fun to_offset(self: &OffsetDateTime, offset: &UtcOffset): OffsetDateTime {
    OffsetDateTime {
        timestamp_ms: self.timestamp_ms,
        offset: *offset,
    }
}
