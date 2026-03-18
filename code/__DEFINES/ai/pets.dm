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

// Cultist pet keys
///our ability to summon runes
#define BB_RUNE_ABILITY "rune_ability"
///the cult team we serve
#define BB_CULT_TEAM "cult_team"
///our dead cultist we revive
#define BB_DEAD_CULTIST "dead_cultist"
///nearby runes
#define BB_NEARBY_RUNE "nearby_rune"
///occupied runes
#define BB_OCCUPIED_RUNE "occupied_rune"
///friendly cultists we befriend
#define BB_FRIENDLY_CULTIST "friendly_cultist"

//cat AI keys
/// key that holds the target we will battle over our turf
#define BB_TRESSPASSER_TARGET "tresspasser_target"
/// key that holds angry meows
#define BB_HOSTILE_MEOWS "hostile_meows"
/// key that holds the mouse target
#define BB_MOUSE_TARGET "mouse_target"
/// key that holds our dinner target
#define BB_CAT_FOOD_TARGET "cat_food_target"
/// key that holds the food we must deliver
#define BB_FOOD_TO_DELIVER "food_to_deliver"
/// key that holds things we can hunt
#define BB_HUNTABLE_PREY "huntable_prey"
/// key that holds target kitten to feed
#define BB_KITTEN_TO_FEED "kitten_to_feed"
/// key that holds our hungry meows
#define BB_HUNGRY_MEOW "hungry_meows"
/// key that holds maximum distance food is to us so we can pursue it
#define BB_MAX_DISTANCE_TO_FOOD "max_distance_to_food"
/// key that holds the stove we must turn off
#define BB_STOVE_TARGET "stove_target"
/// key that holds the donut we will decorate
#define BB_DONUT_TARGET "donut_target"
/// key that holds our home...
#define BB_CAT_HOME "cat_home"
/// key that holds the human we will beg
#define BB_HUMAN_BEG_TARGET "human_beg_target"
