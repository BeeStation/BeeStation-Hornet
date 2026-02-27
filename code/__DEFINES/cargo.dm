#define STYLE_STANDARD 1
#define STYLE_BLUESPACE 2
#define STYLE_CENTCOM 3
#define STYLE_SYNDICATE 4
#define STYLE_BLUE 5
#define STYLE_CULT 6
#define STYLE_MISSILE 7
#define STYLE_RED_MISSILE 8
#define STYLE_BOX 9
#define STYLE_HONK 10
#define STYLE_FRUIT 11
#define STYLE_INVISIBLE 12
#define STYLE_GONDOLA 13
#define STYLE_SEETHROUGH 14
#define STYLE_DROPPOD 15

#define MAX_EMAG_ROCKETS 8
#define BEACON_COST 500
#define SP_LINKED 1
#define SP_READY 2
#define SP_LAUNCH 3
#define SP_UNLINK 4
#define SP_UNREADY 5
#define ORDER_COOLDOWN (10 SECONDS)

#define POD_SHAPE 1
#define POD_BASE 2
#define POD_DOOR 3
#define POD_DECAL 4
#define POD_GLOW 5
#define POD_RUBBLE_TYPE 6
#define POD_NAME 7
#define POD_DESC 8

#define RUBBLE_NONE 1
#define RUBBLE_NORMAL 2
#define RUBBLE_WIDE 3
#define RUBBLE_THIN 4

#define POD_SHAPE_NORML 1
#define POD_SHAPE_OTHER 2

#define POD_TRANSIT "1"
#define POD_FALLING "2"
#define POD_OPENING "3"
#define POD_LEAVING "4"

#define SUPPLYPOD_X_OFFSET -16

GLOBAL_LIST_EMPTY(supplypod_loading_bays)

GLOBAL_LIST_INIT(podstyles, list(\
	//Supply Pod
	list(
		POD_SHAPE_NORML,
		"pod",
		TRUE,
		"default",
		"yellow",
		RUBBLE_NORMAL,
		"supply pod",
		"A Nanotrasen supply drop pod."
	),\
	//BS Supplypod
	list(
		POD_SHAPE_NORML,
		"advpod",
		TRUE,
		"bluespace",
		"blue",
		RUBBLE_NORMAL,
		"bluespace supply pod" ,
		"A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."
	),\
	//CentCom Supplypod
	list(
		POD_SHAPE_NORML,
		"advpod",
		TRUE,
		"centcom",
		"blue",
		RUBBLE_NORMAL,
		"\improper CentCom supply pod",
		"A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to CentCom after delivery."
	),\
	list(
		POD_SHAPE_NORML,
		"darkpod",
		TRUE,
		"syndicate",
		"red",
		RUBBLE_NORMAL,
		"blood-red supply pod",
		"An intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this."
	),\
	list(
		POD_SHAPE_NORML,
		"darkpod",
		TRUE,
		"deathsquad",
		"blue",
		RUBBLE_NORMAL,
		"\improper Deathsquad drop pod",
		"A Nanotrasen drop pod. This one has been marked the markings of Nanotrasen's elite strike team."
	),\
	list(
		POD_SHAPE_NORML,
		"pod",
		TRUE,
		"cultist",
		"red",
		RUBBLE_NORMAL,
		"bloody supply pod",
		"A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes."
	),\
	list(
		POD_SHAPE_OTHER,
		"missile",
		FALSE,
		FALSE,
		FALSE,
		RUBBLE_THIN,
		"cruise missile",
		"A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."
	),\
	list(
		POD_SHAPE_OTHER,
		"smissile",
		FALSE,
		FALSE,
		FALSE,
		RUBBLE_THIN,
		"\improper Syndicate cruise missile",
		"A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."
	),\
	list(
		POD_SHAPE_OTHER,
		"box",
		TRUE,
		FALSE,
		FALSE,
		RUBBLE_WIDE,
		"\improper Aussec supply crate",
		"An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side."
	),\
	//STYLE_HONK 10
	list(
		POD_SHAPE_NORML,
		"clownpod",
		TRUE,
		"clown",
		"green",
		RUBBLE_NORMAL,
		"\improper HONK pod",
		"A brightly-colored supply pod. It likely originated from the Clown Federation."
	),\
	//STYLE_FRUIT 11
	list(
		POD_SHAPE_OTHER,
		"orange",
		TRUE,
		FALSE,
		FALSE,
		RUBBLE_NONE,
		"\improper Orange",
		"An angry orange."
	),\
	//STYLE_INVISIBLE 12
	list(
		POD_SHAPE_OTHER,
		FALSE,
		FALSE,
		FALSE,
		FALSE,
		RUBBLE_NONE,
		"\improper S.T.E.A.L.T.H. pod MKVII",
		"A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?"
	),\
	//STYLE_GONDOLA 13
	list(
		POD_SHAPE_OTHER,
		"gondola",
		FALSE,
		FALSE,
		FALSE,
		RUBBLE_NONE,
		"gondola",
		"The silent walker. This one seems to be part of a delivery agency."
	),\
	//STYLE_SEETHROUGH 14
	list(
		POD_SHAPE_OTHER,
		FALSE,
		FALSE,
		FALSE,
		FALSE,
		RUBBLE_NONE,
		FALSE,
		FALSE,
		"rl_click",
		"give_po"
	),\
	//STYLE_DROPPOD 15
	list(
		POD_SHAPE_NORML,
		"syndicate_droppod",
		TRUE,
		//"syndicate", //TODO: Door
		"red", //TODO: Thruster Glow
		RUBBLE_NORMAL,
		"HELLE drop pod",
		"An intimidating drop pod, covered in thick armored plating. It's probably best to stand back from this."
	),\
))

// ============================================================
// Batch order pricing constants, the single source of truth.
// Tweak these to rebalance batch ordering across the codebase.
// ============================================================

/// Flat surcharge for batch orders (credits). Shrinks linearly to 0 as item count rises.
#define BATCH_SURCHARGE_MAX 200
/// Item count at which the batch surcharge reaches 0.
#define BATCH_SURCHARGE_ITEMS_ZERO 10
/// Item count where the bulk discount starts kicking in.
#define BATCH_BULK_DISCOUNT_START 10
/// Item count where the bulk discount reaches its maximum.
#define BATCH_BULK_DISCOUNT_CAP 40
/// Maximum bulk discount as a fraction (0.20 = 20%).
#define BATCH_BULK_DISCOUNT_MAX 0.30
// Per-type crate costs for batch orders (credits). Fully refunded when crate is sent back.
// These also mirror each crate type's custom_price so export value stays in sync.
#define BATCH_CRATE_COST_STANDARD 200
#define BATCH_CRATE_COST_LARGE 250
#define BATCH_CRATE_COST_INTERNALS 225
#define BATCH_CRATE_COST_MEDICAL 250
#define BATCH_CRATE_COST_RADIATION 250
#define BATCH_CRATE_COST_SECURE 400
#define BATCH_CRATE_COST_SECURE_GEAR 400
#define BATCH_CRATE_COST_SECURE_HYDRO 400
#define BATCH_CRATE_COST_SECURE_WEAPON 450
#define BATCH_CRATE_COST_SECURE_PLASMA 450
#define BATCH_CRATE_COST_ENGINEERING 800
#define BATCH_CRATE_COST_ENGINEERING_ELEC 850
#define BATCH_CRATE_COST_SECURE_ENGI 1000
/// Maximum slots (capacity) that fit in a single crate.
#define BATCH_CRATE_MAX_ITEMS 10
/// How many crate slots a bulky (non-small) item occupies.
#define BATCH_BULKY_ITEM_SLOTS 3
/// Self-paid (personal purchase) surcharge as a whole-number percentage (10 = 10%).
#define BATCH_SELF_PAID_PCT 10
