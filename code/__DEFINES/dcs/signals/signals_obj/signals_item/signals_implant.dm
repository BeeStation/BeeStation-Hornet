// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/item/implant signals
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"			//! from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"			//! from base of /obj/item/implant/proc/implant(): (mob/living/user, mob/living/target)
	#define COMPONENT_STOP_IMPLANTING 1
#define COMSIG_IMPLANT_OTHER "implant_other"					//! called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
	//#define COMPONENT_STOP_IMPLANTING 1 //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT 2
	#define COMPONENT_DELETE_OLD_IMPLANT 4
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"	//! called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
	//This uses all return values of COMSIG_IMPLANT_OTHER

/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"

/// called on implants, after an implant has been removed: (mob/living/source, silent, removed)
#define COMSIG_IMPLANT_REMOVED "implant_removed"
