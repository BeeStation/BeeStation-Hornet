#define MEAT (1<<0)
#define VEGETABLES (1<<1)
#define RAW (1<<2)
#define JUNKFOOD (1<<3)
#define GRAIN (1<<4)
#define FRUIT (1<<5)
#define DAIRY (1<<6)
#define FRIED (1<<7)
#define ALCOHOL (1<<8)
#define SUGAR (1<<9)
#define GROSS (1<<10)
#define TOXIC (1<<11)
#define PINEAPPLE (1<<12)
#define BREAKFAST (1<<13)
#define CLOTH (1<<14)
/*#define NUTS (1<<15)
#define SEAFOOD (1<<16)
#define ORANGES (1<<17)*/
#define BUGS (1<<18)
#define GORE (1<<19)

DEFINE_BITFIELD(foodtypes, list(
	"MEAT" = MEAT,
	"VEGETABLES" = VEGETABLES,
	"RAW" = RAW,
	"JUNKFOOD" = JUNKFOOD,
	"GRAIN" = GRAIN,
	"FRUIT" = FRUIT,
	"DAIRY" = DAIRY,
	"FRIED" = FRIED,
	"ALCOHOL" = ALCOHOL,
	"SUGAR" = SUGAR,
	"GROSS" = GROSS,
	"TOXIC" = TOXIC,
	"PINEAPPLE" = PINEAPPLE,
	"BREAKFAST" = BREAKFAST,
	"CLOTH" = CLOTH,
	"BUGS" = BUGS,
	"GORE" = GORE,
))

/// A list of food type names, in order of their flags
#define FOOD_FLAGS list( \
	"MEAT", \
	"VEGETABLES", \
	"RAW", \
	"JUNKFOOD", \
	"GRAIN", \
	"FRUIT", \
	"DAIRY", \
	"FRIED", \
	"ALCOHOL", \
	"SUGAR", \
	"GROSS", \
	"TOXIC", \
	"PINEAPPLE", \
	"BREAKFAST", \
	"CLOTH", \
	"BUGS", \
	"GORE", \
)

#define DRINK_BAD   1
#define DRINK_NICE	2
#define DRINK_GOOD	3
#define DRINK_VERYGOOD	4
#define DRINK_FANTASTIC	5

#define FOOD_QUALITY_NORMAL 1
#define FOOD_QUALITY_NICE 2
#define FOOD_QUALITY_GOOD 3
#define FOOD_QUALITY_VERYGOOD 4
#define FOOD_QUALITY_FANTASTIC 5
#define FOOD_QUALITY_AMAZING 6
#define FOOD_QUALITY_TOP 7

#define FOOD_COMPLEXITY_0 0
#define FOOD_COMPLEXITY_1 1
#define FOOD_COMPLEXITY_2 2
#define FOOD_COMPLEXITY_3 3
#define FOOD_COMPLEXITY_4 4
#define FOOD_COMPLEXITY_5 5

/// Labels for food quality
GLOBAL_LIST_INIT(food_quality_description, list(
	FOOD_QUALITY_NORMAL = "okay",
	FOOD_QUALITY_NICE = "nice",
	FOOD_QUALITY_GOOD = "good",
	FOOD_QUALITY_VERYGOOD = "very good",
	FOOD_QUALITY_FANTASTIC = "fantastic",
	FOOD_QUALITY_AMAZING = "amazing",
	FOOD_QUALITY_TOP = "godlike",
))

/// Mood events for food quality
GLOBAL_LIST_INIT(food_quality_events, list(
	FOOD_QUALITY_NORMAL = /datum/mood_event/food,
	FOOD_QUALITY_NICE = /datum/mood_event/food/nice,
	FOOD_QUALITY_GOOD = /datum/mood_event/food/good,
	FOOD_QUALITY_VERYGOOD = /datum/mood_event/food/verygood,
	FOOD_QUALITY_FANTASTIC = /datum/mood_event/food/fantastic,
	FOOD_QUALITY_AMAZING = /datum/mood_event/food/amazing,
	FOOD_QUALITY_TOP = /datum/mood_event/food/top,
))

/// Weighted lists of crafted food buffs randomly given according to crafting_complexity unless the food has a specific buff
GLOBAL_LIST_INIT(food_buffs, list(
	FOOD_COMPLEXITY_1 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_2 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_3 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_4 = list(
		/datum/status_effect/food/haste = 1,
	),
	FOOD_COMPLEXITY_5 = list(
		/datum/status_effect/food/haste = 1,
	),
))

/// Food quality change according to species diet
#define DISLIKED_FOOD_QUALITY_CHANGE -2
#define LIKED_FOOD_QUALITY_CHANGE 2
/// Threshold for food to give a toxic reaction
#define TOXIC_FOOD_QUALITY_THRESHOLD -8

/// Food is "in a container", not in a code sense, but in a literal sense (canned foods)
#define FOOD_IN_CONTAINER (1<<0)
/// Finger food can be eaten while walking / running around
#define FOOD_FINGER_FOOD (1<<1)\

DEFINE_BITFIELD(food_types, list(
	"FOOD_FINGER_FOOD" = FOOD_FINGER_FOOD,
	"FOOD_IN_CONTAINER" = FOOD_IN_CONTAINER,
))

#define STOP_SERVING_BREAKFAST (15 MINUTES)

#define IS_EDIBLE(O) (O.GetComponent(/datum/component/edible))

///Food trash flags
#define FOOD_TRASH_POPABLE (1<<0)
#define FOOD_TRASH_OPENABLE (1<<1)

///Food preference enums
#define FOOD_LIKED 1
#define FOOD_DISLIKED 2
#define FOOD_TOXIC 3
