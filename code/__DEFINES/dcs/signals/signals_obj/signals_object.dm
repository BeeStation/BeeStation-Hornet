// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"	//! from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"	//! called in /obj/structure/setAnchored(): (value)
#define COMSIG_OBJ_HIDE	"obj_hide"		//from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide

/// from /obj/proc/make_unfrozen()
#define COMSIG_OBJ_UNFREEZE "obj_unfreeze"
