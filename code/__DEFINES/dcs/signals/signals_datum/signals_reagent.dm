// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/expose_reagents():
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMPONENT_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT "atom_expose_reagent"
///from base of [/datum/reagent/proc/expose_obj]: (/obj, reac_volume, method, show_message)
#define COMSIG_REAGENT_EXPOSE_OBJ "reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_mob]: (/mob/living, method, reac_volume, show_message, touch_protection)
#define COMSIG_REAGENT_EXPOSE_MOB "reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_turf]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF "reagent_expose_turf"
///from base of [/datum/reagent/proc/on_merge]: (list/data, amount)
#define COMSIG_REAGENT_ON_MERGE "reagent_on_merge"
///from base of [/datum/reagents/proc/on_transfer_creation]: (datum/reagents/target_holder, datum/reagent/new_reagent)
#define COMSIG_REAGENT_ON_TRANSFER "reagent_on_transfer"
