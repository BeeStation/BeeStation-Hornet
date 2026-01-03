// These are used in uplink_devices.dm to determine whether or not an item is purchasable.

/// This item is purchasable to traitors
#define UPLINK_TRAITORS (1 << 1)

/// This item is purchasable to nuke ops
#define UPLINK_NUKE_OPS (1 << 2)

/// This item is purchasable to clown ops
#define UPLINK_CLOWN_OPS (1 << 3)

/// This item can be received in a null crate
#define UPLINK_NULL_CRATE (1 << 4)

/// All syndicate uplinks
#define UPLINK_ALL_SYNDIE_OPS (UPLINK_TRAITORS | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/// All uplinks without the null crate
#define UPLINK_WITHOUT_NULL_CRATE (~UPLINK_NULL_CRATE)
