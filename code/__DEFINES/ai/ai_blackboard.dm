// Generic BB keys

#define BB_CURRENT_MIN_MOVE_DISTANCE "min_move_distance"
/// time until we should next eat, set by the generic hunger subtree
#define BB_NEXT_HUNGRY "BB_NEXT_HUNGRY"
/// what we're going to eat next
#define BB_FOOD_TARGET "bb_food_target"
/// Path we should use next time we use the JPS movement datum
#define BB_PATH_TO_USE "BB_path_to_use"

/// song instrument blackboard, set by instrument subtrees
#define BB_SONG_INSTRUMENT "BB_SONG_INSTRUMENT"
/// song lines blackboard, set by default on controllers
#define BB_SONG_LINES "song_lines"

// Hunting BB keys

/// key that holds our current hunting target
#define BB_CURRENT_HUNTING_TARGET "BB_current_hunting_target"
/// key that holds our less priority hunting target
#define BB_LOW_PRIORITY_HUNTING_TARGET "BB_low_priority_hunting_target"
/// key that holds the cooldown for our hunting subtree
#define BB_HUNTING_COOLDOWN "BB_HUNTING_COOLDOWN"

// Targetting subtrees

#define BB_BASIC_MOB_CURRENT_TARGET "BB_basic_current_target"
#define BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION "BB_basic_current_target_hiding_location"
#define BB_TARGETTING_DATUM "targetting_datum"

// Targeting keys for something to run away from, if you need to store this separately from current target

#define BB_BASIC_MOB_FLEE_TARGET "BB_basic_flee_target"
#define BB_BASIC_MOB_FLEE_TARGET_HIDING_LOCATION "BB_basic_flee_target_hiding_location"
#define BB_FLEE_TARGETTING_DATUM "flee_targetting_datum"

// Tipped blackboards

/// Bool that means a basic mob will start reacting to being tipped in its planning
#define BB_BASIC_MOB_TIP_REACTING "BB_basic_tip_reacting"
/// the motherfucker who tipped us
#define BB_BASIC_MOB_TIPPER "BB_basic_tip_tipper"

/// List of mobs who have damaged us
#define BB_BASIC_MOB_RETALIATE_LIST "BB_basic_mob_shitlist"

/// Flag to set on or off if you want your mob to prioritise running away
#define BB_BASIC_MOB_FLEEING "BB_basic_fleeing"

///list of foods this mob likes
#define BB_BASIC_FOODS "BB_basic_foods"

// Modsuit

/// Mob the MOD is trying to attach to
#define BB_MOD_TARGET "BB_mod_target"
/// The implant the AI was created from
#define BB_MOD_IMPLANT "BB_mod_implant"
/// Range for a MOD AI controller.
#define MOD_AI_RANGE 200

// Hostile AI controller blackboard keys

#define BB_FOLLOW_TARGET "BB_FOLLOW_TARGET"
#define BB_ATTACK_TARGET "BB_ATTACK_TARGET"
#define BB_VISION_RANGE "BB_VISION_RANGE"
