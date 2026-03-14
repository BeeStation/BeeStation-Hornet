/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Cannot be used while being absorbed by another changeling. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us. Cannot be used while being absorbed by another changeling."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 0
	req_human = TRUE
	check_flags = NONE
	ignores_fakedeath = TRUE

/datum/action/changeling/headcrab/sting_action(mob/living/user)
	set waitfor = FALSE
	var/confirm = tgui_alert(user, "Are we sure we wish to destroy our body and create a headslug?", "Last Resort", list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/turf/T = user.loc
	if(!T || !isopenturf(T) || !IS_CHANGELING(user))
		to_chat(user, span_warning("You can't become a headslug right now!"))
		return FALSE

	..()
	var/datum/mind/M = user.mind
	var/list/organs = user.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	for(var/mob/living/A in view(2,user))
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			var/obj/item/organ/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
			if(!eyes || H.is_blind())
				continue
			to_chat(H, span_userdanger("You are blinded by a shower of blood!"))
			H.Stun(4 SECONDS)
			H.set_eye_blur_if_lower(40 SECONDS)
			H.adjust_confusion(10 SECONDS)

		else if(issilicon(A))
			var/mob/living/silicon/S = A
			to_chat(S, span_userdanger("Your sensors are disabled by a shower of blood!"))
			S.Paralyze(6 SECONDS)

	// Headcrab transformation is *very* unique; origin mob death happens *before* resulting mob's creation. Action removal should happen beforehand. //You're so weird.
	for(var/datum/action/cp in user.actions)
		cp.Remove(user)
	. = TRUE

	var/mob/living/simple_animal/hostile/headcrab/crab = new(T)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)
	crab.origin = M
	if(!crab.origin)
		return
	crab.origin.active = TRUE
	crab.origin.transfer_to(crab)
	T.transfer_observers_to(crab)
	user.investigate_log("has been gibbed by using their Last Resort headcrab ability.", INVESTIGATE_DEATHS)
	user.gib()
	to_chat(crab, span_warning("You burst out of the remains of your former body in a shower of gore!"))
