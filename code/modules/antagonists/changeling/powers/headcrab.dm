/datum/action/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Cannot be used while being absorbed by another changeling. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us. Cannot be used while being absorbed by another changeling."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 0
	req_human = 1
	req_stat = DEAD
	ignores_fakedeath = TRUE

/datum/action/changeling/headcrab/sting_action(mob/user)
	set waitfor = FALSE
	if(isliving(user))
		var/mob/living/L = user
		var/mob/living/puller = L.pulledby
		if(puller)
			var/datum/antagonist/changeling/other_ling = is_changeling(puller)
			if(other_ling?.isabsorbing)
				to_chat(user, "<span class='warning'>Our last resort is being disrupted by another changeling!</span>")
				return
	if(alert("Are we sure we wish to kill ourself and create a headslug?",,"Yes", "No") == "No")
		return
	..()
	var/datum/mind/M = user.mind
	var/list/organs = user.getorganszone(BODY_ZONE_HEAD, 1)

	for(var/obj/item/organ/I in organs)
		I.Remove(user, 1)

	for(var/mob/living/A in view(2,user))
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
			to_chat(H, "<span class='userdanger'>You are blinded by a shower of blood!</span>")
			H.Stun(20)
			H.blur_eyes(20)
			eyes?.applyOrganDamage(5)
			H.confused += 10
		else if(issilicon(A))
			var/mob/living/silicon/S = A
			to_chat(S, "<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
			S.Paralyze(60)
	var/turf = get_turf(user)
	// Headcrab transformation is *very* unique; origin mob death happens *before* resulting mob's creation. Action removal should happen beforehand.
	for(var/datum/action/cp in user.actions)
		cp.Remove(user)
	user.gib()
	. = TRUE
	var/mob/living/simple_animal/hostile/headcrab/crab = new(turf)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crab)
	crab.origin = M
	if(crab.origin)
		crab.origin.active = 1
		crab.origin.transfer_to(crab)
		to_chat(crab, "<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")
