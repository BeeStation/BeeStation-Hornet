/obj/item/organ/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain"
	visual = TRUE
	throw_speed = 3
	throw_range = 5
	layer = ABOVE_MOB_LAYER
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN
	organ_flags = ORGAN_VITAL|ORGAN_EDIBLE
	attack_verb_continuous = list("attacks", "slaps", "whacks")
	attack_verb_simple = list("attack", "slap", "whack")

	///The brain's organ variables are significantly more different than the other organs, with half the decay rate for balance reasons, and twice the maxHealth
	decay_factor = STANDARD_ORGAN_DECAY	/ 2		//30 minutes of decaying to result in a fully damaged brain, since a fast decay rate would be unfun gameplay-wise

	maxHealth	= BRAIN_DAMAGE_DEATH
	low_threshold = 45
	high_threshold = 120

	organ_traits = list(TRAIT_ADVANCEDTOOLUSER)

	var/suicided = FALSE
	var/mob/living/brain/brainmob = null
	var/brain_death = FALSE //if the brainmob was intentionally killed by attacking the brain after removal, or by severe braindamage
	/// If it's a fake brain with no brainmob assigned. Feedback messages will be faked as if it does have a brainmob. See changelings & dullahans.
	var/decoy_override = FALSE
	/// Two variables necessary for calculating whether we get a brain trauma or not
	var/damage_delta = 0

	var/list/datum/brain_trauma/traumas = list()
	juice_typepath = null	//the moment the brains become juicable, people will find a way to cheese round removal. So NO.

	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/organ/brain/Insert(mob/living/carbon/C, special = 0,no_id_transfer = FALSE, pref_load = FALSE)
	..()

	name = "brain"

	if(C.mind && C.mind.has_antag_datum(/datum/antagonist/changeling) && !no_id_transfer)	//congrats, you're trapped in a body you don't control
		if(brainmob && !(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_DEATHCOMA))))
			to_chat(brainmob, span_danger("You can't feel your body! You're still just a brain!"))
		forceMove(C)
		C.update_hair()
		return

	if(ai_controller && !special)	//are we a monkey brain?
		ai_controller.PossessPawn(C)	//Posession code was designed to handle everything
		ai_controller = null

	if(brainmob)
		if(C.key)
			C.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(C)
		else
			C.key = brainmob.key

		QDEL_NULL(brainmob)

	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		BT.owner = owner
		BT.on_gain()

	//Update the body's icon so it doesnt appear debrained anymore
	C.update_hair()

/obj/item/organ/brain/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE, pref_load = FALSE)
	..()
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		BT.on_lose(TRUE)
		BT.owner = null

	if(C.ai_controller && !special)	//special is called in humanisation/dehumanisation
		C.ai_controller.set_ai_status(AI_STATUS_OFF)
		src.ai_controller = C.ai_controller	//AI is stored in the brain but doesn't control it.
		C.ai_controller.UnpossessPawn(FALSE)	//The body no longer has AI.

	if((!gc_destroyed || (owner && !owner.gc_destroyed)) && !no_id_transfer)
		if(C.mind)
			transfer_identity(C)
			if(C.mind.current)
				C.mind.transfer_to(brainmob)
		to_chat(brainmob, span_notice("You feel slightly disoriented. That's normal when you're just a brain."))
	C.update_hair()

/obj/item/organ/brain/setOrganDamage(d)
	. = ..()
	if(brain_death && !(organ_flags & ORGAN_FAILING))
		brain_death = FALSE
		brainmob.revive(TRUE) // We fixed the brain, fix the brainmob too.

/obj/item/organ/brain/proc/transfer_identity(mob/living/L)
	name = "[L.name]'s brain"
	if(brainmob || decoy_override)
		return
	brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	brainmob.timeofhostdeath = L.timeofdeath
	brainmob.suiciding = suicided
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
		if(HAS_TRAIT(L, TRAIT_BADDNA))
			LAZYSET(brainmob.status_traits, TRAIT_BADDNA, L.status_traits[TRAIT_BADDNA])
		var/obj/item/organ/zombie_infection/ZI = L.getorganslot(ORGAN_SLOT_ZOMBIE)
		if(ZI)
			brainmob.set_species(ZI.old_species)	//For if the brain is cloned

/obj/item/organ/brain/attackby(obj/item/O, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)

	if(istype(O, /obj/item/organ_storage))
		return //Borg organ bags shouldn't be killing brains

	if((organ_flags & ORGAN_FAILING) && O.is_drainable() && O.reagents.has_reagent(/datum/reagent/medicine/mannitol)) //attempt to heal the brain
		. = TRUE //don't do attack animation.

		if(!O.reagents.has_reagent(/datum/reagent/medicine/mannitol, 10))
			to_chat(user, span_warning("There's not enough mannitol in [O] to restore [src]!"))
			return

		user.visible_message("[user] starts to pour the contents of [O] onto [src].", span_notice("You start to slowly pour the contents of [O] onto [src]."))
		if(!do_after(user, 60, src))
			to_chat(user, span_warning("You failed to pour [O] onto [src]!"))
			return

		user.visible_message("[user] pours the contents of [O] onto [src], causing it to reform its original shape and turn a slightly brighter shade of pink.", span_notice("You pour the contents of [O] onto [src], causing it to reform its original shape and turn a slightly brighter shade of pink."))
		setOrganDamage(damage - (0.05 * maxHealth))	//heals a small amount, and by using "setorgandamage", we clear the failing variable if that was up
		O.reagents.clear_reagents()
		return

	if(brainmob) //if we aren't trying to heal the brain, pass the attack onto the brainmob.
		O.attack(brainmob, user) //Oh noooeeeee

	if(O.force != 0 && !(O.item_flags & NOBLUDGEON))
		setOrganDamage(maxHealth) //fails the brain as the brain was attacked, they're pretty fragile.

/obj/item/organ/brain/examine(mob/user)
	. = ..()

	if(suicided)
		. += span_info("It's started turning slightly grey. They must not have been able to handle the stress of it all.")
	else if(brainmob)
		if(!brainmob.soul_departed())
			if(brain_death || brainmob.health <= HEALTH_THRESHOLD_DEAD)
				. += span_info("It's lifeless and severely damaged.")
			else if(organ_flags & ORGAN_FAILING)
				. += span_info("It seems to still have a bit of energy within it, but it's rather damaged... You may be able to restore it with some <b>mannitol</b>.")
			else
				. += span_info("You can feel the small spark of life still left in this one.")
		else if(organ_flags & ORGAN_FAILING)
			. += span_info("It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.")
		else
			. += span_info("This one seems particularly lifeless. Perhaps it will regain some of its luster later.")
	else
		if(decoy_override)
			if(organ_flags & ORGAN_FAILING)
				. += span_info("It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.")
			else
				. += span_info("This one seems particularly lifeless. Perhaps it will regain some of its luster later.")
		else
			. += span_info("This one is completely devoid of life.")

/obj/item/organ/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		QDEL_NULL(brainmob)
	QDEL_LIST(traumas)

	if(owner?.mind) //You aren't allowed to return to brains that don't exist
		owner.mind.set_current(null)
	return ..()

// We really don't want people eating brains unless they're zombies.
/obj/item/organ/brain/pre_eat(eater, feeder)
	if(!iszombie(eater))
		return FALSE
	return TRUE

// Ditto for composting
/obj/item/organ/brain/pre_compost(user)
	return FALSE

/obj/item/organ/brain/on_life(delta_time, times_fired)
	if(damage >= BRAIN_DAMAGE_DEATH) //rip
		to_chat(owner, span_userdanger("The last spark of life in your brain fizzles out."))
		owner.investigate_log("has been killed by brain damage.", INVESTIGATE_DEATHS)
		owner.death()
		brain_death = TRUE

/obj/item/organ/brain/check_damage_thresholds(mob/M)
	. = ..()
	//if we're not more injured than before, return without gambling for a trauma
	if(damage <= prev_damage)
		return
	damage_delta = damage - prev_damage
	if(damage > BRAIN_DAMAGE_MILD)
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_MILD)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1% //learn how to do your bloody math properly goddamnit
			gain_trauma_type(BRAIN_TRAUMA_MILD)

	var/is_boosted = (owner && HAS_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST))
	if(damage > BRAIN_DAMAGE_SEVERE)
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_SEVERE)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1%
			if(prob(20 + (is_boosted * 30)))
				gain_trauma_type(BRAIN_TRAUMA_SPECIAL, is_boosted ? TRAUMA_RESILIENCE_SURGERY : null)
			else
				gain_trauma_type(BRAIN_TRAUMA_SEVERE)

	if (owner)
		if(owner.stat < UNCONSCIOUS) //conscious or soft-crit
			var/brain_message
			if(prev_damage < BRAIN_DAMAGE_MILD && damage >= BRAIN_DAMAGE_MILD)
				brain_message = span_warning("You feel lightheaded.")
			else if(prev_damage < BRAIN_DAMAGE_SEVERE && damage >= BRAIN_DAMAGE_SEVERE)
				brain_message = span_warning("You feel less in control of your thoughts.")
			else if(prev_damage < (BRAIN_DAMAGE_DEATH - 20) && damage >= (BRAIN_DAMAGE_DEATH - 20))
				brain_message = span_warning("You can feel your mind flickering on and off.")

			if(.)
				. += "\n[brain_message]"
			else
				return brain_message

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	// Dont inherit adv_tool_user
	organ_traits = null

/obj/item/organ/brain/diona
	name = "diona nymph"
	desc = "A small mass of roots and plant matter, it looks to be moving."
	icon_state = "diona_brain"
	decoy_override = TRUE

/obj/item/organ/brain/diona/Remove(mob/living/carbon/C, special, no_id_transfer, pref_load)
	if(special)
		return
	C.dna.species.spec_death(FALSE, src)
	QDEL_NULL(src)

/obj/item/organ/brain/positron
	name = "positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	status = ORGAN_ROBOTIC
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. In order for this Posibrain to be used as a newly built Positronic Brain, it must be coupled with an MMI."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain-ipc"
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/brain/positron/Insert(mob/living/carbon/C, special = 0, drop_if_replaced = 0)
	..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.dna?.species)
			if(REVIVESBYHEALING in H.dna.species.species_traits)
				if(H.health > 0 && !H.ishellbound())
					H.revive(0)

/obj/item/organ/brain/positron/emp_act(severity)
	owner.apply_status_effect(/datum/status_effect/ipc/emp)
	to_chat(owner, span_warning("Alert: Posibrain function disrupted."))

////////////////////////////////////TRAUMAS////////////////////////////////////////

/obj/item/organ/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE, special_method = FALSE)
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(!istype(BT, brain_trauma_type))
			continue
		if(special_method && CHECK_BITFIELD(BT.trauma_flags, TRAUMA_SPECIAL_CURE_PROOF))
			continue
		if(BT.resilience > resilience)
			continue
		. += BT

/obj/item/organ/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE, special_method = FALSE)
	. = list()
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(!istype(BT, brain_trauma_type))
			continue
		if(special_method && CHECK_BITFIELD(BT.trauma_flags, TRAUMA_SPECIAL_CURE_PROOF))
			continue
		if(BT.resilience > resilience)
			continue
		. += BT

/obj/item/organ/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience)
	if(!ispath(trauma))
		trauma = trauma.type
	if(!initial(trauma.can_gain))
		return FALSE
	if(!resilience)
		resilience = initial(trauma.resilience)

	var/resilience_tier_count = 0
	for(var/X in traumas)
		if(istype(X, trauma))
			return FALSE
		var/datum/brain_trauma/T = X
		if(resilience == T.resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

//Proc to use when directly adding a trauma to the brain, so extra args can be given
/obj/item/organ/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

//Direct trauma gaining proc. Necessary to assign a trauma to its brain. Avoid using directly.
/obj/item/organ/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma() //arglist with an empty list runtimes for some reason
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) //we don't accept used traumas here
		WARNING("gain_trauma was given an already active trauma.")
		return
	if(QDELETED(actual_trauma)) // hypnosis might qdel on New, causing problems
		stack_trace("brain_gain_trauma tried to add qdeleted trauma.")
		return

	traumas += actual_trauma
	actual_trauma.brain = src
	if(owner)
		actual_trauma.owner = owner
		actual_trauma.on_gain()
	if(resilience)
		actual_trauma.resilience = resilience
	. = actual_trauma
	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)

//Add a random trauma of a certain subtype
/obj/item/organ/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/T in subtypesof(brain_trauma_type))
		var/datum/brain_trauma/BT = T
		if(can_gain_trauma(BT, resilience) && !CHECK_BITFIELD(initial(BT.trauma_flags), TRAUMA_NOT_RANDOM))
			possible_traumas += BT

	if(!LAZYLEN(possible_traumas))
		return

	var/trauma_type = pick(possible_traumas)
	gain_trauma(trauma_type, resilience)

//Cure a random trauma of a certain resilience level
/obj/item/organ/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC, special_method = FALSE)
	var/list/traumas = get_traumas_type(brain_trauma_type, resilience, special_method)
	if(LAZYLEN(traumas))
		qdel(pick(traumas))

/obj/item/organ/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC, special_method = FALSE)
	var/list/traumas = get_traumas_type(resilience = resilience, special_method = special_method)
	for(var/X in traumas)
		qdel(X)

