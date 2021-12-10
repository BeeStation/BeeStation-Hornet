#define REM REAGENTS_EFFECT_MULTIPLIER

GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/build_name2reagent()
	. = list()
	for (var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		if (length(initial(R.name)))
			.[ckey(initial(R.name))] = t


//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/datum/reagent
	var/name = "Reagent"
	var/description = ""
	var/specific_heat = SPECIFIC_HEAT_DEFAULT		//J/(K*mol)
	var/taste_description = "metaphorical salt"
	var/taste_mult = 1 //how this taste compares to others. Higher values means it is more noticable
	var/glass_name = "glass of ...what?" // use for specialty drinks.
	var/glass_desc = "You can't really tell what this is."
	var/glass_icon_state = null // Otherwise just sets the icon to a normal glass with the mixture of the reagents in the glass.
	var/shot_glass_icon_state = null
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0									//pretend this is moles
	/// pH of the reagent
	var/ph = 7
	///Purity of the reagent - for use with internal reaction mechanics only. Use below (creation_purity) if you're writing purity effects into a reagent's use mechanics.
	var/purity = 1
	///the purity of the reagent on creation (i.e. when it's added to a mob and it's purity split it into 2 chems; the purity of the resultant chems are kept as 1, this tracks what the purity was before that)
	var/creation_purity = 1
	var/color = "#000000" // rgb: 0, 0, 0
	var/can_synth = TRUE // can this reagent be synthesized? (for example: odysseus syringe gun)
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/random_unrestricted = TRUE
	var/process_flags = ORGANIC // What can process this? ORGANIC, SYNTHETIC, or ORGANIC | SYNTHETIC?. We'll assume by default that it affects organics.
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/self_consuming = FALSE
	var/reagent_weight = 1 //affects how far it travels when sprayed
	var/metabolizing = FALSE
	/// See fermi_readme.dm REAGENT_DEAD_PROCESS, REAGENT_DONOTSPLIT, REAGENT_INVISIBLE, REAGENT_SNEAKYNAME, REAGENT_SPLITRETAINVOL
	var/chemical_flags = NONE
	///impure chem values (see fermi_readme.dm for more details on impure/inverse/failed mechanics):
	/// What chemical path is made when metabolised as a function of purity
	var/impure_chem = /datum/reagent/impurity
	/// If the impurity is below 0.5, replace ALL of the chem with inverse_chem upon metabolising
	var/inverse_chem_val = 0.25
	/// What chem is metabolised when purity is below inverse_chem_val
	var/inverse_chem = /datum/reagent/impurity/toxic
	///what chem is made at the end of a reaction IF the purity is below the recipies purity_min at the END of a reaction only
	var/failed_chem = /datum/reagent/consumable/failed_reaction
	/// is it bad for you? Currently only used for borghypo. C2s and Toxins have it TRUE by default.
	var/harmful = FALSE
	/// Are we from a material? We might wanna know that for special stuff. Like metalgen. Is replaced with a ref of the material on New()
	var/datum/material/material
	///A list of causes why this chem should skip being removed, if the length is 0 it will be removed from holder naturally, if this is >0 it will not be removed from the holder.
	var/list/reagent_removal_skip_list = list()
	///The set of exposure methods this penetrates skin with.
	var/penetrates_skin = VAPOR

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/// Applies this reagent to an [/atom]
/datum/reagent/proc/expose_atom(atom/A, volume)
	SHOULD_CALL_PARENT(TRUE)
/datum/reagent/proc/expose_atom(atom/exposed_atom, reac_volume)
	SHOULD_CALL_PARENT(TRUE)

	. = 0
	. |= SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_ATOM, exposed_atom, reac_volume)
	. |= SEND_SIGNAL(exposed_atom, COMSIG_ATOM_EXPOSE_REAGENT, src, reac_volume)

/datum/reagent/proc/expose_mob(mob/living/M, methods=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(methods & VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = CLAMP((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(type, amount)
	return 1
	SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_ATOM, exposed_atom, reac_volume)
	SEND_SIGNAL(exposed_atom, COMSIG_ATOM_EXPOSE_REAGENT, src, reac_volume)
	return TRUE

/// Applies this reagent to a [/mob/living]
/datum/reagent/proc/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_MOB, exposed_mob, methods, reac_volume, show_message, touch_protection)
	if((methods & penetrates_skin) && exposed_mob.reagents) //smoke, foam, spray
		var/amount = round(reac_volume*clamp((1 - touch_protection), 0, 1), 0.1)
		if(amount >= 0.5)
			exposed_mob.reagents.add_reagent(type, amount)
	return TRUE

/datum/reagent/proc/expose_obj(obj/O, volume)
	return
/// Applies this reagent to an [/obj]
/datum/reagent/proc/expose_obj(obj/exposed_obj, reac_volume)
	SHOULD_CALL_PARENT(TRUE)

/datum/reagent/proc/expose_turf(turf/T, volume)
	return
	SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_OBJ, exposed_obj, reac_volume)
	return TRUE

/// Applies this reagent to a [/turf]
/datum/reagent/proc/expose_turf(turf/exposed_turf, reac_volume)
	SHOULD_CALL_PARENT(TRUE)

	SEND_SIGNAL(src, COMSIG_REAGENT_EXPOSE_TURF, exposed_turf, reac_volume)
	return TRUE

/// Called from [/datum/reagents/proc/metabolize]
/datum/reagent/proc/on_mob_life(mob/living/carbon/M)
	current_cycle++
	holder.remove_reagent(type, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

/*
Used to run functions before a reagent is transfered. Returning TRUE will block the transfer attempt.
Primarily used in reagents/reaction_agents
*/
/datum/reagent/proc/intercept_reagents_transfer(datum/reagents/target)
	return FALSE

/datum/reagent/proc/on_transfer(atom/A, methods=TOUCH, trans_volume)
	return

// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L, amount)
	return

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/L)
	return

// Called when this reagent first starts being metabolized by a liver
/datum/reagent/proc/on_mob_metabolize(mob/living/L)
	return

// Called when this reagent stops being metabolized by a liver
/datum/reagent/proc/on_mob_end_metabolize(mob/living/L)
	return

/// Called when a reagent is inside of a mob when they are dead
/datum/reagent/proc/on_mob_dead(mob/living/carbon/C)
	if(!(chemical_flags & REAGENT_DEAD_PROCESS))
		return
	current_cycle++
	if(length(reagent_removal_skip_list))
		return
	holder.remove_reagent(type, metabolization_rate * C.metabolism_efficiency)

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data, amount)
	return

/datum/reagent/proc/on_update(atom/A)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M)
	return

/datum/reagent/proc/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You feel like you took too much of [name]!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_light, name)
	if(prob(30))
		to_chat(M, "<span class='notice'>You feel like having some [name] right about now.</span>")
	return

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_medium, name)
	if(prob(30))
		to_chat(M, "<span class='notice'>You feel like you need [name]. You just can't get enough.</span>")
	return

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_severe, name)
	if(prob(30))
		to_chat(M, "<span class='danger'>You have an intense craving for [name].</span>")
	return

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_critical, name)
	if(prob(30))
		to_chat(M, "<span class='boldannounce'>You're not feeling good at all! You really need some [name].</span>")
	return

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")
