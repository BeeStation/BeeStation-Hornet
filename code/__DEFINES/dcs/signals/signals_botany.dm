/*
	Plant signals
		Plant signals refer to signals sent by the plant component
*/

///From datum/plant_feature/body/process(): ()
#define COMSIG_PLANT_GROW_FINAL "COMSIG_PLANT_GROWN"

//Other things also send this signal, so you should probably do some homework on that if you're messing with this
///From datum/plant_feature/fruit/proc/catch_attack_hand(): (mob/user, list/temp_fruits, dummy_harvest = FALSE))
#define COMSIG_PLANT_ACTION_HARVEST "COMSIG_PLANT_ACTION_HARVEST"

///From datum/plant_feature/body/proc/setup_fruit(): (harvest_amount, list/_visual_fruits)
#define COMSIG_PLANT_REQUEST_FRUIT "COMSIG_PLANT_REQUEST_FRUIT"

//Lots of places send this signal as the parent. Essentially, roots listen for this signal to supply reagents to whomever
///From everywhere() : (list/reagent_holders, datum/requestor))
#define COMSIG_PLANT_REQUEST_REAGENTS "COMSIG_PLANT_REQUEST_REAGENTS"

///From whenever a plant is planted, called in a coupled places : (atom/destination)
#define COMSIG_PLANT_PLANTED "COMSIG_PLANT_PLANTED"
///From whenever a plant is uprooted, including destroyed, called in a couple places : (mob/user, obj/item/tool, atom/old_loc)
#define COMSIG_PLANT_UPROOTED "COMSIG_PLANT_UPROOTED"

//From /datum/component/plant/proc/catch_spade_attack(): (atom/location)
#define COMSIG_PLANT_POLL_TRAY_SIZE "COMSIG_PLANT_POLL_TRAY_SIZE"

//From /datum/plant_feature/proc/check_needs(): (datum/plant_feature/failing_feature)
#define COMSIG_PLANT_NEEDS_FAILS "COMSIG_PLANT_NEEDS_FAILS"
//From /datum/plant_feature/proc/check_needs(): (datum/plant_feature/passing_feature)
#define COMSIG_PLANT_NEEDS_PASS "COMSIG_PLANT_NEEDS_PASS"
//From /datum/plant_feature/proc/check_needs(): (datum/component/plant)
#define COMSIG_PLANT_NEEDS_PAUSE "COMSIG_PLANT_NEEDS_PAUSE"

#define COMSIG_PLANT_NECTAR_BUFF "COMSIG_PLANT_NECTAR_BUFF"
#define COMSIG_PLANT_BEE_BUFF "COMSIG_PLANT_BEE_BUFF"
#define COMSIG_PLANT_CARNI_BUFF "COMSIG_PLANT_CARNI_BUFF"

/*
	Plant Feature Signals
		PF signals refer to plant features
		Generic signals shared across all plant features
*/

///From datum/plant_feature/proc/setup_parent(): ()
#define COMSIG_PF_ATTACHED_PARENT "COMSIG_PF_ATTACHED_PARENT"

/*
	Fruit Signals
		Fruit signals refer to the fruit plant feature
		Signals unique to fruit features
*/
#define COMSIG_FRUIT_PREPARE "COMSIG_FRUIT_PREPARE"
#define COMSIG_FRUIT_BUILT "COMSIG_FRUIT_BUILT"
#define COMSIG_FRUIT_BUILT_POST "COMSIG_FRUIT_BUILT_POST"

#define COMSIG_FRUIT_ACTIVATE_NO_CONTEXT "COMSIG_FRUIT_ACTIVATE_GENERIC"
#define COMSIG_FRUIT_ACTIVATE_TARGET "COMSIG_FRUIT_ACTIVATE_TARGET"

/*
	Seed Signals
		Signals for seeds, mostly used for scalable / quick interactions with features
*/
#define COMSIG_SEEDS_POLL_ROOT_SUBSTRATE "COMSIG_SEEDS_POLL_ROOT_SUBSTRATE"
#define COMSIG_SEEDS_POLL_TRAY_SIZE "COMSIG_PLANT_OCCUPY_TRAY"

/*
	Tray signals
		Used for tray component
*/
#define COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP "COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP"
#define COMSIG_PLANTER_UPDATE_SUBSTRATE "COMSIG_PLANTER_UPDATE_SUBSTRATE"
#define COMSIG_PLANTER_TICK_REAGENTS "COMSIG_PLANTER_TICK_REAGENTS"
#define COMSIG_PLANTER_PAUSE_PLANT "COMSIG_PLANTER_PAUSE_PLANT"

/*
	Plant gene signals
		Just used to fetch stuff from the gene element
*/
#define COMSIG_PLANT_GET_GENES "COMSIG_PLANT_GET_GENES"

/*
	Trait signals
		used for special conditions when traits are trying to pretend to be optimized
*/
#define COMSIG_ASSEMBLER_GET_OPERATIONS "COMSIG_ASSEMBLER_GET_OPERATIONS"
