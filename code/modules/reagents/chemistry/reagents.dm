/// A single reagent
/datum/reagent
	abstract_type = /datum/reagent

	/// datums don't have names by default
	var/name = "Reagent"
	/// nor do they have descriptions
	var/description = ""
	///J/(K*mol)
	var/specific_heat = SPECIFIC_HEAT_DEFAULT
	/// used by taste messages
	var/taste_description = "metaphorical salt"
	///how this taste compares to others. Higher values means it is more noticable
	var/taste_mult = 1
	/// reagent holder this belongs to
	var/datum/reagents/holder = null
	/// LIQUID, SOLID, GAS
	var/reagent_state = LIQUID
	/// special data associated with this like viruses etc
	var/list/data
	/// increments everytime on_mob_life is called
	var/current_cycle = 0
	///pretend this is moles
	var/volume = 0
	/// color it looks in containers etc
	var/color = COLOR_BLACK
	/// intensity of color provided, dyes or things that should work like a dye will more strongly affect the final color of a reagent
	var/color_intensity = 1
	///how fast the reagent is metabolized by the mob
	var/metabolization_rate = REAGENTS_METABOLISM
	/// Will be added as the reagent is processed
	var/metabolite
	/// above this overdoses happen
	var/overdose_threshold = 0
	// What can process this? ORGANIC, SYNTHETIC, or ORGANIC | SYNTHETIC?. We'll assume by default that it affects organics.
	var/process_flags = ORGANIC
	/// You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/overdosed = FALSE
	///if false stops metab in liverless mobs
	var/self_consuming = FALSE
	///affects how far it travels when sprayed
	var/reagent_weight = 1
	///is it currently metabolizing
	VAR_FINAL/metabolizing = FALSE
	///The set of exposure methods this penetrates skin with.
	var/penetrates_skin = VAPOR
	var/chemical_flags = NONE
	/// How we interact with random generators
	var/randomized_spawns = NONE
	/**
	 * Lazyassoc list of [addiction typepath] to [threshold value].
	 *
	 * [threshold value] can be interpreted as the number of units that must be consumed before an addiction is formed.
	 *
	 * Ex: list(/datum/addiction/stimulants = 50) -> "become addicted to stimulants after metabolizing 50 units of this reagent".
	 */
	var/list/addiction_types = null
	/// The affected organ_flags, if the reagent damages/heals organ damage of an affected mob.
	/// See "Organ defines for carbon mobs" in /code/_DEFINES/surgery.dm
	var/affected_organ_flags = ORGAN_ORGANIC
	/// The affected bodytype, if the reagent damages/heals bodyparts (Brute/Fire) of an affected mob.
	/// See "Bodytype defines" in /code/_DEFINES/mobs.dm
	var/affected_bodytype = BODYTYPE_ORGANIC
	/// The affected biotype, if the reagent damages/heals toxin damage of an affected mob.
	/// See "Mob bio-types flags" in /code/_DEFINES/mobs.dm
	var/affected_biotype = MOB_ORGANIC
	/// A list of traits to apply while the reagent is being metabolized.
	var/list/metabolized_traits
	/// A list of traits to apply while the reagent is in a mob.
	var/list/added_traits

	///The default reagent container for the reagent, used for icon generation
	var/obj/default_container = /obj/item/reagent_containers/cup/bottle

	/// Icon for fallback item displayed in a tourist's thought bubble for if this reagent had no associated glass_style datum.
	var/fallback_icon
	/// Icon state for fallback item displayed in a tourist's thought bubble for if this reagent had no associated glass_style datum.
	var/fallback_icon_state

/// This should only be called by the holder, so it's already handled clearing its references
/datum/reagent/Destroy()
	. = ..()
	holder = null

/// Applies this reagent to an [/atom]
/datum/reagent/proc/expose_atom(atom/exposed_atom, reac_volume, methods = TOUCH)
	SHOULD_CALL_PARENT(TRUE)

	. = 0
	. |= SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_ATOM, exposed_atom, reac_volume, methods)
	. |= SEND_SIGNAL(exposed_atom, COMSIG_ATOM_EXPOSE_REAGENT, src, reac_volume, methods)

/// Applies this reagent to a [/mob/living]
/datum/reagent/proc/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0, obj/item/bodypart/affecting)
	SHOULD_CALL_PARENT(TRUE)

	if(SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_MOB, exposed_mob, methods, reac_volume, show_message, touch_protection) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	if(isnull(exposed_mob.reagents)) // lots of simple mobs do not have a reagents holder
		return

	if(penetrates_skin & methods) // models things like vapors which penetrate the skin
		var/amount = round(reac_volume * clamp((1 - touch_protection), 0, 1), 0.1)
		if(amount >= 0.5)
			exposed_mob.reagents.add_reagent(type, amount, reagtemp = holder.chem_temp)

/// Applies this reagent to an [/obj]
/datum/reagent/proc/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	SHOULD_CALL_PARENT(TRUE)

	return SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_OBJ, exposed_obj, reac_volume, methods, show_message)

/// Applies this reagent to a [/turf]
/datum/reagent/proc/expose_turf(turf/exposed_turf, reac_volume)
	SHOULD_CALL_PARENT(TRUE)

	return SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_TURF, exposed_turf, reac_volume)

///Called to begin metabolization and return the volume of reagent to metabolize
/datum/reagent/proc/compute_metabolization(mob/living/carbon/affected_mob, seconds_per_tick)
	SHOULD_BE_PURE(TRUE)
	var/metabolizing_out = metabolization_rate * seconds_per_tick
	if(!(chemical_flags & REAGENT_UNAFFECTED_BY_METABOLISM))
		if(chemical_flags & REAGENT_REVERSE_METABOLISM)
			metabolizing_out /= affected_mob.metabolism_efficiency
		else
			metabolizing_out *= affected_mob.metabolism_efficiency

	return min(metabolizing_out, volume)

/**
 * Ticks on mob Life() for as long as the reagent remains in the mob's reagents.
 *
 * Usage: Parent should be called first using . = ..()
 *
 * Exceptions: If the holder var needs to be accessed, call the parent afterward that as it can become null if the reagent is fully removed.
 *
 * Returns: UPDATE_MOB_HEALTH only if you need to update the health of a mob (this is only needed when damage is dealt to the mob)
 *
 * Arguments
 * * mob/living/carbon/affected_mob - the mob which the reagent currently is inside of
 * * seconds_per_tick - the time in server seconds between proc calls (when performing normally it will be 2)
 *
 */
/datum/reagent/proc/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	SHOULD_CALL_PARENT(TRUE)

///Metabolizes a portion of the reagent after on_mob_life() is called
/datum/reagent/proc/metabolize_reagent(mob/living/carbon/affected_mob, seconds_per_tick, metabolized_volume)
	if(isnull(holder))
		return
	if(metabolite)
		holder.add_reagent(metabolite, metabolized_volume * METABOLITE_RATE)
	volume -= metabolized_volume
	holder.update_total()

/**
 * Intercepts the reagent transfer/copy operation to do some work before it takes place.
 * Used to perform some reaction work. Return TRUE To cancel the operation
 *
 * Arguments
 *
 * * datum/reagents/target - the target holder we are being transferred to
 * * amount - the amount of reagent being transferred
 * * copy_only - if TRUE we don't remove ourself from the holder because its a reagent copy & not transfer operation
*/
/datum/reagent/proc/intercept_reagents_transfer(datum/reagents/target, amount, copy_only)
	return FALSE

/// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/affected_mob, amount)
	SHOULD_CALL_PARENT(TRUE)
	if(added_traits)
		affected_mob.add_traits(added_traits, "base:[type]")

/// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/affected_mob)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(affected_mob, COMSIG_CLEAR_MOOD_EVENT, "[type]_overdose")
	REMOVE_TRAITS_IN(affected_mob, "base:[type]")

/// Called when this reagent first starts being metabolized by a liver
/datum/reagent/proc/on_mob_metabolize(mob/living/affected_mob)
	SHOULD_CALL_PARENT(TRUE)
	if(metabolized_traits)
		affected_mob.add_traits(metabolized_traits, "metabolize:[type]")

/// Called when this reagent stops being metabolized by a liver
/datum/reagent/proc/on_mob_end_metabolize(mob/living/affected_mob, metabolization_ratio)
	SHOULD_CALL_PARENT(TRUE)
	REMOVE_TRAITS_IN(affected_mob, "metabolize:[type]")

/**
 * Called when a reagent is inside of a mob when they are dead if the reagent has the REAGENT_DEAD_PROCESS flag
 * Returning UPDATE_MOB_HEALTH will cause updatehealth() to be called on the holder mob by /datum/reagents/proc/metabolize.
 */
/datum/reagent/proc/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	SHOULD_CALL_PARENT(TRUE)

/**
 * Called after add_reagents creates a new reagent.
 *
 * Arguments
 * * data - if not null, contains reagent data which will be applied to the newly created reagent (this will override any pre-set data).
 */
/datum/reagent/proc/on_new(data)
	SHOULD_CALL_PARENT(TRUE)
	if(data)
		src.data = data

/// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(list/mix_data, amount)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_REAGENT_ON_MERGE, mix_data, amount)

/// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects. Returning UPDATE_MOB_HEALTH will cause updatehealth() to be called on the holder mob by /datum/reagents/proc/metabolize.
/datum/reagent/proc/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	return

/// Called when an overdose starts. Returning UPDATE_MOB_HEALTH will cause updatehealth() to be called on the holder mob by /datum/reagents/proc/metabolize.
/datum/reagent/proc/overdose_start(mob/living/affected_mob, metabolization_ratio)
	to_chat(affected_mob, span_userdanger("You feel like you took too much of [name]!"))
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

///Convert reagent list to a printable string for logging etc
/proc/pretty_string_from_reagent_list(list/reagent_list)
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")
