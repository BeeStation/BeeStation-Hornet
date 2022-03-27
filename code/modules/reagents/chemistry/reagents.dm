#define REM REAGENTS_EFFECT_MULTIPLIER

// synthesizable part - can this reagent be synthesized? (for example: odysseus syringe gun)
#define CHEMICAL_NOT_DEFINED   (1<<0)  // identical to CHEMICAL_NOT_SYNTH, but it is good to label when you are not sure which flag you should set on it, or something that shouldn't exist in the game. - i.e) medicine parent type
#define CHEMICAL_NOT_SYNTH     (1<<0)  // no it can't.

// RNG part - having this flag will allow the RNG system to put in.
// if a reagent hasn't a relevant flag, it wouldn't come out from RNG theme - i.e.) maint pill
#define CHEMICAL_BASIC_ELEMENT (1<<1)  // basic chemicals in chemistry - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_BASIC_DRINK   (1<<2)  // basic chemicals in bartending - currently used in botany RNG (not yet - refactored for prepration)
#define CHEMICAL_RNG_GENERAL   (1<<3)  // it spawns in general stuff - i.e.) vent, abductor gland
#define CHEMICAL_RNG_FUN       (1<<4)  // it spawns in maint pill or something else nasty. This usually has a dramatically interesting list including admin stuff minus some lame ones.
#define CHEMICAL_RNG_BOTANY    (1<<5)  // it spawns in botany strange seeds

// crew objective part - having this flag will allow an objective having a reagent
#define CHEMICAL_GOAL_CHEMIST_DRUG         (1<<6)  // chemist objective - i.e.) make 24 pills of 12u meth
#define CHEMICAL_GOAL_CHEMIST_BLOODSTREAM  (1<<7)  // chemist objective - i.e.) eat meth in your bloodstream
#define CHEMICAL_GOAL_BOTANIST_HARVEST     (1<<8)  // botanist objective - i.e.) make 12 crops of 10u omnizine
#define CHEMICAL_GOAL_BARTENDER_SERVING    (1<<9) // !NOTE: not implemented, but refactored for preparation - i.e.) serve Bacchus' blessing to 10 crews

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
	var/taste_mult = 1  //how this taste compares to others. Higher values means it is more noticable
	var/glass_name = "glass of ...what?" // use for specialty drinks.
	var/glass_desc = "You can't really tell what this is."
	var/glass_icon_state = null // Otherwise just sets the icon to a normal glass with the mixture of the reagents in the glass.
	var/shot_glass_icon_state = null
	var/datum/reagents/holder = null
	var/reagent_state = LIQUID
	var/list/data
	var/current_cycle = 0
	var/volume = 0 //pretend this is moles
	var/color = "#000000" // rgb: 0, 0, 0
	var/chem_flags = CHEMICAL_NOT_DEFINED   // default = I am not sure this shit + CHEMICAL_NOT_SYNTH
	var/metabolization_rate = REAGENTS_METABOLISM //how fast the reagent is metabolized by the mob
	var/overrides_metab = 0
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/process_flags = ORGANIC // What can process this? ORGANIC, SYNTHETIC, or ORGANIC | SYNTHETIC?. We'll assume by default that it affects organics.
	var/overdosed = 0 // You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/self_consuming = FALSE
	var/reagent_weight = 1 //affects how far it travels when sprayed
	var/metabolizing = FALSE

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return 0
	if(method == VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = CLAMP((1 - touch_protection), 0, 1)
			var/amount = round(reac_volume*modifier, 0.1)
			if(amount >= 0.5)
				M.reagents.add_reagent(type, amount)
	return 1

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/carbon/M)
	current_cycle++
	holder.remove_reagent(type, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

/datum/reagent/proc/on_transfer(atom/A, method=TOUCH, trans_volume) //Called after a reagent is transfered
	return

/datum/reagents/proc/react_single(datum/reagent/R, atom/A, method = TOUCH, volume_modifier = 1, show_message = TRUE)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
		if(method == INGEST)
			var/mob/living/L = A
			L.taste(src)
	else if(isturf(A))
		react_type = "TURF"
	else if(isobj(A))
		react_type = "OBJ"
	else
		return
	switch(react_type)
		if("LIVING")
			var/touch_protection = 0
			if(method == VAPOR)
				var/mob/living/L = A
				touch_protection = L.get_permeability_protection()
			R.reaction_mob(A, method, R.volume * volume_modifier, show_message, touch_protection)
		if("TURF")
			R.reaction_turf(A, R.volume * volume_modifier, show_message)
		if("OBJ")
			R.reaction_obj(A, R.volume * volume_modifier, show_message)

// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L)
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

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
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
