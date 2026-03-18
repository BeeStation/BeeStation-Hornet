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

//A couple places use this, it's just a buff condition
//From /datum/plant_trait/nectar/proc/catch_bee(): no arguments, just the source
#define COMSIG_PLANT_NECTAR_BUFF "COMSIG_PLANT_NECTAR_BUFF"
//The floral gun also uses this
//From /mob/living/simple_animal/hostile/poison/bees/proc/pollinate(): no arguments, just the source
#define COMSIG_PLANT_BEE_BUFF "COMSIG_PLANT_BEE_BUFF"
//From /datum/plant_trait/roots/carnivore/process(): (_delta_time)
#define COMSIG_PLANT_CARNI_BUFF "COMSIG_PLANT_CARNI_BUFF"

/*
	Plant Feature Signals
		PF signals refer to plant features
		Generic signals shared across all plant features
*/

///From datum/plant_feature/proc/setup_parent(): no arguments, just the source
#define COMSIG_PF_ATTACHED_PARENT "COMSIG_PF_ATTACHED_PARENT"

/*
	Fruit Signals
		Fruit signals refer to the fruit plant feature
		Signals unique to fruit features
*/
//From /datum/plant_feature/fruit/proc/build_fruit(): (obj/produce)
#define COMSIG_FRUIT_PREPARE "COMSIG_FRUIT_PREPARE"
//From /datum/plant_feature/fruit/proc/build_fruit(): (obj/produce)
#define COMSIG_FRUIT_BUILT "COMSIG_FRUIT_BUILT"
//From /datum/plant_feature/fruit/proc/build_fruit(): (obj/produce)
#define COMSIG_FRUIT_BUILT_POST "COMSIG_FRUIT_BUILT_POST"

/*
	These are passed from activator traits to trigger plant traits, like gaseous
*/
//From fruit trait datums : ()
#define COMSIG_FRUIT_ACTIVATE_NO_CONTEXT "COMSIG_FRUIT_ACTIVATE_GENERIC"
//From fruit trait datums : (datum/trait, atom/target)
#define COMSIG_FRUIT_ACTIVATE_TARGET "COMSIG_FRUIT_ACTIVATE_TARGET"

/*
	Seed Signals
		Signals for seeds, mostly used for scalable / quick interactions with features
*/
//From /datum/component/plant/proc/catch_spade_attack(): (datum/substrate)
#define COMSIG_SEEDS_POLL_ROOT_SUBSTRATE "COMSIG_SEEDS_POLL_ROOT_SUBSTRATE"
//From /obj/item/plant_seeds/proc/plant(): (obj/planter)
#define COMSIG_SEEDS_POLL_TRAY_SIZE "COMSIG_PLANT_OCCUPY_TRAY"

/*
	Tray signals
		Used for tray component
*/
//From /datum/component/planter/proc/set_substrate(): (datum/substrate)
#define COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP "COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP"
//From /datum/component/planter/proc/set_substrate(): (datum/substrate)
#define COMSIG_PLANTER_UPDATE_SUBSTRATE "COMSIG_PLANTER_UPDATE_SUBSTRATE"
//From /datum/component/planter/process(): (datum/planter, _delta_time)
#define COMSIG_PLANTER_TICK_REAGENTS "COMSIG_PLANTER_TICK_REAGENTS"
//This is used in a couple places, but essentially just used to see if we pause some functionaility. Send from tray / plant location
//From /datum/plant_feature/body/process(): No Arguments, just the source
#define COMSIG_PLANTER_PAUSE_PLANT "COMSIG_PLANTER_PAUSE_PLANT"

/*
	Plant gene signals
		Just used to fetch stuff from the gene element
*/
//Used in a couple places to get a list of a thing's plant genes
//From /proc/seedify(): (list/list_to_populate)
#define COMSIG_PLANT_GET_GENES "COMSIG_PLANT_GET_GENES"
