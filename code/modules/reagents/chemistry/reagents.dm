GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/build_name2reagent()
	. = list()
	for (var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		if (length(initial(R.name)))
			.[ckey(initial(R.name))] = t

///Convert reagent list to a printable string for logging etc
/proc/pretty_string_from_reagent_list(list/reagent_list)
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")


//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/// A single reagent
/datum/reagent
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
	var/color = "#000000" // rgb: 0, 0, 0
	/// intensity of color provided, dyes or things that should work like a dye will more strongly affect the final color of a reagent
	var/color_intensity = 1
	// default = I am not sure this shit + CHEMICAL_NOT_SYNTH
	var/chemical_flags = CHEMICAL_NOT_DEFINED
	///how fast the reagent is metabolized by the mob
	var/metabolization_rate = REAGENTS_METABOLISM
	/// A list of traits to apply while the reagent is being metabolized.
	var/list/metabolized_traits
	/// A list of traits to apply while the reagent is in a mob.
	var/list/added_traits
	/// Will be added as the reagent is processed
	var/metabolite
	/// above this overdoses happen
	var/overdose_threshold = 0
	/// above this amount addictions start
	var/addiction_threshold = 0
	/// increases as addiction gets worse
	var/addiction_stage = 0
	// What can process this? ORGANIC, SYNTHETIC, or ORGANIC | SYNTHETIC?. We'll assume by default that it affects organics.
	var/process_flags = ORGANIC
	/// You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/overdosed = FALSE
	///if false stops metab in liverless mobs
	var/self_consuming = FALSE
	///affects how far it travels when sprayed
	var/reagent_weight = 1
	///is it currently metabolizing
	var/metabolizing = FALSE

	///The default reagent container for the reagent, used for icon generation
	var/obj/item/reagent_containers/default_container = /obj/item/reagent_containers/cup/bottle

	// Used for restaurants.
	///The amount a robot will pay for a glass of this (20 units but can be higher if you pour more, be frugal!)
	var/glass_price
	/// Icon for fallback item displayed in a tourist's thought bubble for if this reagent had no associated glass_style datum.
	var/fallback_icon
	/// Icon state for fallback item displayed in a tourist's thought bubble for if this reagent had no associated glass_style datum.
	var/fallback_icon_state

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/// Applies this reagent to an [/atom]
/datum/reagent/proc/expose_atom(atom/exposed_atom, reac_volume)
	SEND_SIGNAL(exposed_atom, COMSIG_ATOM_EXPOSE_REAGENT, src, reac_volume)
	return

/// Applies this reagent to a [/mob/living]
/datum/reagent/proc/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	if(!istype(exposed_mob))
		return FALSE
	if(method == VAPOR) //smoke, foam, spray
		if(exposed_mob.reagents)
			var/modifier = clamp((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume * modifier, 0.1)
			if(amount >= 0.5)
				exposed_mob.reagents.add_reagent(type, amount)
	return TRUE

/// Applies this reagent to an [/obj]
/datum/reagent/proc/expose_obj(obj/exposed_obj, volume)
	SHOULD_CALL_PARENT(TRUE)

/// Applies this reagent to a [/turf]
/datum/reagent/proc/expose_turf(turf/exposed_turf, volume)
	SHOULD_CALL_PARENT(TRUE)

/// Called from [/datum/reagents/proc/metabolize]
/datum/reagent/proc/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	current_cycle++

	if(!QDELETED(holder))
		holder.remove_reagent(type, metabolization_rate * affected_mob.metabolism_efficiency * delta_time) //By default it slowly disappears.
		if(metabolite)
			holder.add_reagent(metabolite, metabolization_rate * affected_mob.metabolism_efficiency * METABOLITE_RATE * delta_time)

///Called after a reagent is transfered
/datum/reagent/proc/on_transfer(atom/A, method = TOUCH, trans_volume)
	SHOULD_CALL_PARENT(TRUE)

/// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/carbon/affected_mob, amount)
	SHOULD_CALL_PARENT(TRUE)
	if(added_traits)
		affected_mob.add_traits(added_traits, "base:[type]")

/// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/carbon/affected_mob)
	SHOULD_CALL_PARENT(TRUE)
	REMOVE_TRAITS_IN(affected_mob, "base:[type]")

/// Called when this reagent first starts being metabolized by a liver
/datum/reagent/proc/on_mob_metabolize(mob/living/carbon/affected_mob)
	SHOULD_CALL_PARENT(TRUE)
	if(metabolized_traits)
		affected_mob.add_traits(metabolized_traits, "metabolize:[type]")

/// Called when this reagent stops being metabolized by a liver
/datum/reagent/proc/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	SHOULD_CALL_PARENT(TRUE)
	REMOVE_TRAITS_IN(affected_mob, "metabolize:[type]")

/// Called by [/datum/reagents/proc/conditional_update_move]
/datum/reagent/proc/on_move(mob/M)
	SHOULD_CALL_PARENT(TRUE)

/// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	SHOULD_CALL_PARENT(TRUE)
	if(data)
		src.data = data

/// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	SHOULD_CALL_PARENT(TRUE)

/// Called by [/datum/reagents/proc/conditional_update]
/datum/reagent/proc/on_update(atom/A)
	SHOULD_CALL_PARENT(TRUE)

/// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/carbon/affected_mob, delta_time, times_fired)
	SHOULD_CALL_PARENT(TRUE)

/// Called when an overdose starts
/datum/reagent/proc/overdose_start(mob/living/carbon/affected_mob)
	to_chat(affected_mob, span_userdanger("You feel like you took too much of [name]!"))
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/// Called when addiction hits stage1, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage1(mob/living/carbon/affected_mob)
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_light, name)
	if(prob(30))
		to_chat(affected_mob, span_notice("You feel like having some [name] right about now."))

/// Called when addiction hits stage2, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage2(mob/living/carbon/affected_mob)
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_medium, name)
	if(prob(30))
		to_chat(affected_mob, span_notice("You feel like you need [name]. You just can't get enough."))

/// Called when addiction hits stage3, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage3(mob/living/carbon/affected_mob)
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_severe, name)
	if(prob(30))
		to_chat(affected_mob, span_danger("You have an intense craving for [name]."))

/// Called when addiction hits stage4, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage4(mob/living/carbon/affected_mob)
	SEND_SIGNAL(affected_mob, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_critical, name)
	if(prob(30))
		to_chat(affected_mob, span_boldannounce("You're not feeling good at all! You really need some [name]."))
