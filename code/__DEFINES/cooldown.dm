
// Action cooldown groups. Starts at 1
#define CD_GROUP_USER_ACTION 1	// Actions which apply to the user
#define CD_GROUP_TELEKENISIS 2	// Telekenetic actions
#define CD_GROUP_EXTERNAL 3		// External actions which cannot be sped up
#define CD_GROUP_GUARDIAN 4		// Guardian actionsuser

/// The highest cooldown group. Adding more will make mobs use slightly more memory
/// but won't impact performance for the most part.
#define CD_GROUP_MAX 4

// Action click cooldowns, in tenths of a second, used for various combat actions
#define CLICK_CD_MELEE 8
#define CLICK_CD_THROW 4
#define CLICK_CD_RANGE 4
#define CLICK_CD_RAPID 2
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_BREAKOUT 100
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_RESIST 20
#define CLICK_CD_GRABBING 10
#define CLICK_CD_LOOK_DIRECTION 5
#define CLICK_CD_REPAIR 4
