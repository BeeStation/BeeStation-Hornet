///Dog AI controller blackboard keys
#define BB_SIMPLE_CARRY_ITEM "BB_SIMPLE_CARRY_ITEM"
#define BB_FETCH_IGNORE_LIST "BB_FETCH_IGNORE_LISTlist"
#define BB_FETCH_DELIVER_TO "BB_FETCH_DELIVER_TO"
#define BB_DOG_HARASS_TARGET "BB_DOG_HARASS_TARGET"
#define BB_DOG_HARASS_HARM "BB_DOG_HARASS_HARM"
#define BB_DOG_IS_SLOW "BB_DOG_IS_SLOW"

/// Basically, what is our vision/hearing range for picking up on things to fetch/
#define AI_DOG_VISION_RANGE	10
/// What are the odds someone petting us will become our friend?
#define AI_DOG_PET_FRIEND_PROB 15
/// After this long without having fetched something, we clear our ignore list
#define AI_FETCH_IGNORE_DURATION (30 SECONDS)

///Baby-making blackboard
///Types of animal we can make babies with.
#define BB_BABIES_PARTNER_TYPES "BB_babies_partner"
///Types of animal that we make as a baby.
#define BB_BABIES_CHILD_TYPES "BB_babies_child"
///Current partner target
#define BB_BABIES_TARGET "BB_babies_target"
///Timeout for finding partners when theres too many of us in 1 location
#define BB_PARTNER_SEARCH_TIMEOUT "BB_partner_search_timeout"

///the name of our trick
#define BB_TRICK_NAME "trick_name"
///the sequence of our trick
#define BB_TRICK_SEQUENCE "trick_sequence"
