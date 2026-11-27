// Atom reagent signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/expose_reagents():
#define COMSIG_ATOM_EXPOSE_REAGENTS "atom_expose_reagents"
	/// Prevents the atom from being exposed to reagents if returned on [COMPONENT_ATOM_EXPOSE_REAGENTS]
	#define COMPONENT_NO_EXPOSE_REAGENTS (1<<0)
///from base of [/datum/reagent/proc/expose_atom]: (/datum/reagent, reac_volume)
#define COMSIG_ATOM_EXPOSE_REAGENT "atom_expose_reagent"
///from base of [/datum/reagent/proc/expose_atom]: (/atom, reac_volume, methods)
#define COMSIG_REAGENT_EXPOSE_ATOM "reagent_expose_atom"
///from base of [/datum/reagent/proc/expose_obj]: (/obj, reac_volume, methods, show_message)
#define COMSIG_REAGENT_EXPOSE_OBJ "reagent_expose_obj"
///from base of [/datum/reagent/proc/expose_mob]: (/mob/living, methods, reac_volume, show_message, touch_protection)
#define COMSIG_REAGENT_EXPOSE_MOB "reagent_expose_mob"
///from base of [/datum/reagent/proc/expose_turf]: (/turf, reac_volume)
#define COMSIG_REAGENT_EXPOSE_TURF "reagent_expose_turf"
///from base of [/datum/reagent/proc/on_merge]: (list/data, amount)
#define COMSIG_REAGENT_ON_MERGE "reagent_on_merge"
///from base of [/datum/reagents/proc/trans_to] when a new reagent is created in the target: (datum/reagents/target_holder, datum/reagent/new_reagent)
#define COMSIG_REAGENT_ON_TRANSFER "reagent_on_transfer"

///from base of [/datum/reagents/proc/update_total]
#define COMSIG_REAGENTS_HOLDER_UPDATED "reagents_update_total"
///from base of [/datum/reagents/proc/set_temperature]: (new_temp, old_temp)
#define COMSIG_REAGENTS_TEMP_CHANGE "reagents_temp_change"
///from base of [/datum/reagents/proc/process]: (num_reactions, seconds_per_tick)
#define COMSIG_REAGENTS_REACTION_STEP "reagents_time_step"
