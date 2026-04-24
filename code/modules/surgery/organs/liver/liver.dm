#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_RESISTANCE 1 //lower values lower how harmful toxins are to the liver
#define LIVER_FAILURE_STAGE_SECONDS 60 //amount of seconds before liver failure reaches a new stage

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = "Pairing suggestion: chianti and fava beans."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

	/// Affects how much damage the liver takes from alcohol
	var/alcohol_tolerance = ALCOHOL_RATE
	/// The maximum volume of toxins the liver will ignore
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE
	/// Modifies how much damage toxin deals to the liver
	var/liver_resistance = LIVER_DEFAULT_TOX_RESISTANCE
	var/filterToxins = TRUE //whether to filter toxins

/obj/item/organ/liver/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_SPECIES_HANDLE_CHEMICAL, PROC_REF(handle_chemical))
	RegisterSignal(organ_owner, COMSIG_ATOM_EXAMINE, PROC_REF(on_owner_examine))

/obj/item/organ/liver/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_SPECIES_HANDLE_CHEMICAL, COMSIG_ATOM_EXAMINE))

/**
 * This proc can be overriden by liver subtypes so they can handle certain chemicals in special ways.
 * Return null to continue running the normal on_mob_life() for that reagent.
 * Return COMSIG_MOB_STOP_REAGENT_CHECK to not run the normal metabolism effects.
 *
 * NOTE: If you return COMSIG_MOB_STOP_REAGENT_CHECK, that reagent will not be removed like normal! You must handle it manually.
 **/
/obj/item/organ/liver/proc/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

/obj/item/organ/liver/on_life(delta_time, times_fired)
	. = ..() //perform general on_life()
	//If your liver is failing or you lack a metabolism then we use the liverless version of metabolize
	if((organ_flags & ORGAN_FAILING) || HAS_TRAIT(owner, TRAIT_LIVERLESS_METABOLISM))
		owner.reagents.end_metabolization(keep_liverless = TRUE)
		owner.reagents.metabolize(owner, delta_time, times_fired, can_overdose=TRUE, liverless=TRUE)
		return

	owner.reagents?.metabolize(owner, delta_time, times_fired, can_overdose=TRUE)

/obj/item/organ/liver/handle_failing_organs(delta_time)
	if(HAS_TRAIT(owner, TRAIT_STABLELIVER) || HAS_TRAIT(owner, TRAIT_LIVERLESS_METABOLISM))
		return
	return ..()

/obj/item/organ/liver/organ_failure(delta_time)
	switch(failure_time/LIVER_FAILURE_STAGE_SECONDS)
		if(1)
			to_chat(owner, span_userdanger("You feel stabbing pain in your abdomen!"))
		if(2)
			to_chat(owner, span_userdanger("You feel a burning sensation in your gut!"))
			owner.vomit()
		if(3)
			to_chat(owner, span_userdanger("You feel painful acid in your throat!"))
			owner.vomit(blood = TRUE)
		if(4)
			to_chat(owner, span_userdanger("Overwhelming pain knocks you out!"))
			owner.vomit(blood = TRUE, distance = rand(1,2))
			owner.emote("Scream")
			owner.AdjustUnconscious(2.5 SECONDS)
		if(5)
			to_chat(owner, span_userdanger("You feel as if your guts are about to melt!"))
			owner.vomit(blood = TRUE,distance = rand(1,3))
			owner.emote("Scream")
			owner.AdjustUnconscious(5 SECONDS)

	switch(failure_time)
		//After 60 seconds we begin to feel the effects
		if(1 * LIVER_FAILURE_STAGE_SECONDS to 2 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.2 * delta_time,forced = TRUE)
			owner.adjust_disgust(0.1 * delta_time)

		if(2 * LIVER_FAILURE_STAGE_SECONDS to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.4 * delta_time,forced = TRUE)
			owner.adjust_drowsiness(0.5 SECONDS * delta_time)
			owner.adjust_disgust(0.3 * delta_time)

		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			owner.adjustToxLoss(0.6 * delta_time,forced = TRUE)
			owner.adjustOrganLoss(pick(ORGAN_SLOT_HEART,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_EYES,ORGAN_SLOT_EARS),0.2 * delta_time)
			owner.adjust_drowsiness(1 SECONDS * delta_time)
			owner.adjust_disgust(0.6 * delta_time)

			if(DT_PROB(1.5, delta_time))
				owner.emote("drool")

		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			owner.adjustToxLoss(0.8 * delta_time,forced = TRUE)
			owner.adjustOrganLoss(pick(ORGAN_SLOT_HEART,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_EYES,ORGAN_SLOT_EARS),0.5 * delta_time)
			owner.adjust_drowsiness(1.6 SECONDS * delta_time)
			owner.adjust_disgust(1.2 * delta_time)

			if(DT_PROB(3, delta_time))
				owner.emote("drool")

/obj/item/organ/liver/proc/on_owner_examine(datum/source, mob/user, list/examine_list)
	if(!ishuman(owner) || !(organ_flags & ORGAN_FAILING))
		return

	var/mob/living/carbon/human/humie_owner = owner
	if(!humie_owner.get_organ_slot(ORGAN_SLOT_EYES) || humie_owner.is_eyes_covered())
		return
	switch(failure_time)
		if(0 to 3 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[owner]'s eyes are slightly yellow.")
		if(3 * LIVER_FAILURE_STAGE_SECONDS to 4 * LIVER_FAILURE_STAGE_SECONDS - 1)
			examine_list += span_notice("[owner]'s eyes are completely yellow, and [owner.p_they()] [owner.p_are()] visibly suffering.")
		if(4 * LIVER_FAILURE_STAGE_SECONDS to INFINITY)
			examine_list += span_danger("[owner]'s eyes are completely yellow and swelling with pus. [owner.p_they(TRUE)] [owner.p_do()]n't look like [owner.p_they()] will be alive for much longer.")

/obj/item/organ/liver/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantliver

/obj/item/organ/liver/fly
	name = "insectoid liver"
	icon_state = "liver-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant liver designed to handle the unique diet of a flyperson."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/plasmaman
	name = "reagent processing crystal"
	desc = "A large crystal that is somehow capable of metabolizing chemicals, these are found in plasmamen."
	icon_state = "liver-p"
	organ_flags = ORGAN_MINERAL

/obj/item/organ/liver/alien
	name = "alien liver" // doesnt matter for actual aliens because they dont take toxin damage
	icon_state = "liver-x" // Same sprite as fly-person liver.
	desc = "A liver that used to belong to a killer alien, who knows what it used to eat."
	toxTolerance = 15 // complete toxin immunity like xenos have would be too powerful
	liver_resistance = 0.333 * LIVER_DEFAULT_TOX_RESISTANCE // -66%

/obj/item/organ/liver/cybernetic
	name = "cybernetic liver"
	desc = "A very basic device designed to mimic the functions of a human liver. Handles toxins slightly worse than an organic liver."
	icon_state = "liver-c"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5
	toxTolerance = 2
	liver_resistance = 0.9 * LIVER_DEFAULT_TOX_RESISTANCE // -10%

/obj/item/organ/liver/cybernetic/tier2
	name = "cybernetic liver"
	desc = "An upgraded version of the cybernetic liver, designed to improve further upon organic livers. It is resistant to alcohol poisoning and is very robust at filtering toxins."
	icon_state = "liver-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5 //can shrug off up to 5u of toxins
	liver_resistance = 1.2 * LIVER_DEFAULT_TOX_RESISTANCE // +20%
	emp_vulnerability = 40

/obj/item/organ/liver/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		damage += (30/severity)

/obj/item/organ/liver/cybernetic/tier2/ipc
	name = "substance processor"
	icon_state = "substance_processor"
	attack_verb_continuous = list("processes")
	attack_verb_simple = list("process")
	desc = "A machine component, installed in the chest. This grants the Machine the ability to process chemicals that enter its systems."
	alcohol_tolerance = 0
	toxTolerance = -1

/obj/item/organ/liver/cybernetic/tier2/ipc/emp_act(severity)
	if(prob(30/severity))
		to_chat(owner, span_warning("Alert: Your Substance Processor has been damaged. An internal chemical leak is affecting performance."))
		owner.adjustToxLoss(8/severity)

/obj/item/organ/liver/diona
	name = "liverwort"
	desc = "A mass of plant vines and leaves, seeming to be responsible for chemical digestion."
	icon_state = "diona_liver"

#undef LIVER_DEFAULT_TOX_TOLERANCE
#undef LIVER_DEFAULT_TOX_RESISTANCE
#undef LIVER_FAILURE_STAGE_SECONDS
