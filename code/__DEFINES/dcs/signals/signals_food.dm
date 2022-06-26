//Food
/// from base of obj/item/food/attack(): (mob/living/eater, mob/feeder)
#define COMSIG_FOOD_EATEN "food_eaten"
///from base of datum/component/edible/oncrossed: (mob/crosser, bitecount)
#define COMSIG_FOOD_CROSSED "food_crossed"
#define COMSIG_ITEM_FRIED "item_fried"
	#define COMSIG_FRYING_HANDLED (1<<0)
///from base of Component/edible/On_Consume: (mob/living/eater, mob/living/feeder)
#define COMSIG_FOOD_CONSUMED "food_consumed"
///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_griddled"
	#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_GRILL_COMPLETED "item_grill_completed"
//Called when an object is in an oven
#define COMSIG_ITEM_BAKED "item_baked"
	#define COMPONENT_HANDLED_BAKING (1<<0)
	#define COMPONENT_BAKING_GOOD_RESULT (1<<1)
	#define COMPONENT_BAKING_BAD_RESULT (1<<2)
///Called when an object is turned into another item through baking in an oven
#define COMSIG_BAKE_COMPLETED "item_bake_completed"
