// These are used in uplink_devices.dm to determine whether or not an item is purchasable.

/// This item is purchasable to incursionists
#define UPLINK_INCURSION (1 << 0)

/// This item is purchasable to traitors
#define UPLINK_TRAITORS (1 << 1)

/// This item is purchasable to nuke ops
#define UPLINK_NUKE_OPS (1 << 2)

/// This item is purchasable to clown ops
#define UPLINK_CLOWN_OPS (1 << 3)

//Uplink spawn loc, bonuses
#define UPLINK_DISCOUNT_DEFAULT 3

#define UPLINK_PDA "PDA"
#define UPLINK_PDA_DISCOUNT 5
#define UPLINK_PDA_WITH_DESC "[UPLINK_PDA] ([UPLINK_PDA_DISCOUNT] discounts)"
#define UPLINK_RADIO "Radio"
#define UPLINK_RADIO_DISCOUNT 4
#define UPLINK_RADIO_WITH_DESC "[UPLINK_RADIO] ([UPLINK_RADIO_DISCOUNT] discounts)"
#define UPLINK_PEN "Pen" //like a real spy!
#define UPLINK_PEN_DISCOUNT 4
#define UPLINK_PEN_WITH_DESC "[UPLINK_PEN] ([UPLINK_PEN_DISCOUNT] discounts)"
#define UPLINK_IMPLANT "Implant"
#define UPLINK_IMPLANT_DISCOUNT 3
#define UPLINK_IMPLANT_WITH_DESC "[UPLINK_IMPLANT] ([UPLINK_IMPLANT_DISCOUNT] discounts)"
