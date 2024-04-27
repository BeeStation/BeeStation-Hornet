//Food

// Eating stuff
/// From datum/component/edible/proc/TakeBite: (mob/living/eater, mob/feeder, bitecount, bitesize)
#define COMSIG_FOOD_EATEN "food_eaten"
/// From base of datum/component/edible/on_entered: (mob/crosser, bitecount)
#define COMSIG_FOOD_CROSSED "food_crossed"
/// From base of Component/edible/On_Consume: (mob/living/eater, mob/living/feeder)
#define COMSIG_FOOD_CONSUMED "food_consumed"
///called when an atom with /datum/component/customizable_reagent_holder is customized (obj/item/I)
#define COMSIG_ATOM_CUSTOMIZED "atom_customized"
/// called when an item is used as an ingredient: (atom/customized)
#define COMSIG_ITEM_USED_AS_INGREDIENT "item_used_as_ingredient"
/// called when an edible ingredient is added: (datum/component/edible/ingredient)
#define COMSIG_FOOD_INGREDIENT_ADDED "edible_ingredient_added"

// Deep frying foods
/// An item becomes fried - From /datum/element/fried_item/Attach: (fry_time)
#define COMSIG_ITEM_FRIED "item_fried"
/// An item entering the deep frying (not fried yet) - From obj/machinery/deepfryer/start_fry: ()
#define COMSIG_ITEM_ENTERED_FRYER "item_entered_fryer"

// Microwaving foods
///called on item when microwaved (): (obj/machinery/microwave/microwave, mob/microwaver)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
	#define COMPONENT_SUCCESFUL_MICROWAVE (1<<0)
///called on item when created through microwaving (): (obj/machinery/microwave/M, cooking_efficiency)
#define COMSIG_ITEM_MICROWAVE_COOKED "microwave_cooked"

// Grilling foods (griddle, grill, and bonfire)
///Called when an object is placed onto a griddle
#define COMSIG_ITEM_GRILL_PLACED "item_placed_on_griddle"
///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILL_PROCESS "item_griddled"
	/// Return to not burn the item
	#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_grill_completed"

#define COMSIG_GRILL_COMPLETED "grill_completed"
///Called when an object is meant to be grilled through a grill: (atom/fry_object, grill_time)
#define COMSIG_GRILL_FOOD "item_grill_food"

///From /datum/component/edible/on_compost(source, /mob/living/user)
#define COMSIG_EDIBLE_ON_COMPOST "on_compost"
	// Used to stop food from being composted.
	#define COMPONENT_EDIBLE_BLOCK_COMPOST 1
