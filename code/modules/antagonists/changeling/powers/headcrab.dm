/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Cannot be used while being absorbed by another changeling. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us. Cannot be used while being absorbed by another changeling."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 0
	req_human = 1
	check_flags = NONE
	ignores_fakedeath = TRUE

/datum/action/changeling/headcrab/sting_action(mob/user)
	set waitfor = FALSE
	if(alert("Are we sure we wish to kill ourself and create a headslug?",,"Yes", "No") != "Yes")
		return
	if(isliving(user))
		var/mob/living/L = user
		var/mob/living/puller = L.pulledby
		if(puller)
			var/datum/antagonist/changeling/other_ling = IS_CHANGELING(puller)
			if(other_ling?.isabsorbing)
				to_chat(user, span_warning("Our last resort is being disrupted by another changeling!"))
				return
	var/turf/T = user.loc
	if(!T || !isopenturf(T) || !IS_CHANGELING(user))
		to_chat(user, span_warning("You can't become a headslug right now!"))
		return FALSE
	var/datum/mind/M = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)
	..()

	for(var/obj/item/organ/I in organs)
		I.Remove(user, 1)

	for(var/mob/living/A in view(2,user))
		if(ishuman(A))
			var/mob/living/carbon/human/splashed = A
			var/obj/item/organ/eyes/eyes = splashed.get_organ_slot(ORGAN_SLOT_EYES)
			to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
			splashed.Stun(2 SECONDS)
			splashed.set_eye_blur_if_lower(40 SECONDS)
			eyes?.applyOrganDamage(5)
			splashed.adjust_confusion(3 SECONDS)
		else if(issilicon(A))
			var/mob/living/silicon/S = A
			to_chat(S, span_userdanger("Your sensors are disabled by a shower of blood!"))
			S.Paralyze(60)
	// Headcrab transformation is *very* unique; origin mob death happens *before* resulting mob's creation. Action removal should happen beforehand.
	for(var/datum/action/cp in user.actions)
		cp.Remove(user)
	. = TRUE
	var/mob/living/simple_animal/hostile/headcrab/crab = new(T)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)
	crab.origin = M
	if(crab.origin)
		crab.origin.active = 1
		crab.origin.transfer_to(crab)
		user.investigate_log("has been gibbed by using their Last Resort headcrab ability.", INVESTIGATE_DEATHS)
		user.gib()
		to_chat(crab, span_warning("You burst out of the remains of your former body in a shower of gore!"))
