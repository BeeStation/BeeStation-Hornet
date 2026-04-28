// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals

///from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
///from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
///from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide
#define COMSIG_OBJ_HIDE "obj_hide"

/// from /obj/proc/make_unfrozen()
#define COMSIG_OBJ_UNFREEZE "obj_unfreeze"

// /obj signals for economy
///called when the payment component tries to charge an account.
#define COMSIG_OBJ_ATTEMPT_CHARGE "obj_attempt_simple_charge"
	#define COMPONENT_OBJ_CANCEL_CHARGE  (1<<0)
///Called when a payment component changes value
#define COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE "obj_attempt_simple_charge_change"

/// called once a mindshield is implanted: (mob/user)
#define COMSIG_MINDSHIELD_IMPLANTED "mindshield_implanted"

///from /obj/item/assembly/proc/pulsed(mob/pulser)
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"

/// Called on a mob attempting to use a ladder to go in either direction.  (entrance_ladder, exit_ladder, going_up)
#define COMSIG_LADDER_TRAVEL "ladder-travel"
	#define LADDER_TRAVEL_BLOCK (1<<0)

/// Called in /obj/structure/closet/PopulateContents()
#define COMSIG_CLOSET_CONTENTS_INITIALIZED "closet_initialize_contents"
