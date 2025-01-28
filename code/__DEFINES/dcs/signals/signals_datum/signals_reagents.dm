///from base of atom/expose_reagents(): (/list, /datum/reagents, methods, volume_modifier, show_message)
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMPONENT_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT	"atom_expose_reagent"
///from base of [/datum/reagent/proc/expose_atom]: (/atom, reac_volume)
#define COMSIG_REAGENT_EXPOSE_ATOM	"reagent_expose_atom"
///from base of [/datum/reagent/proc/expose_atom]: (/obj, reac_volume)
#define COMSIG_REAGENT_EXPOSE_OBJ	"reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_atom]: (/mob/living, reac_volume, methods, show_message, touch_protection, /mob/camera/blob) // ovemind arg is only used by blob reagents.
#define COMSIG_REAGENT_EXPOSE_MOB	"reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_atom]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF	"reagent_expose_turf"
