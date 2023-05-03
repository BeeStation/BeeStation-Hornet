/obj/effect/proc_holder/spell/targeted/hive_thrall
	name = "Awaken Vessel"
	desc = "We awaken one of our vessels, permanently turning them into an extension of our will, we can only sustain two awakened vessels increasing with integrations."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = INVOCATION_NONE
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "chaos"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_thrall/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if((hivehost.avessels.len >= hivehost.avessel_limit) && !hivehost.dominant)
		to_chat(user, "<span class='notice'>We can't support another awakened vessel!</span>")
		return
	var/mob/living/carbon/human/target = user.pulling
	if(!target)
		to_chat(user, "<span class='warning'>We must be grabbing a creature to awaken them!</span>")
		hivehost.isintegrating = FALSE
		revert_cast()
		return
	if(!is_hivemember(target))
		to_chat(user, "<span class='warning'>They must be a vessel in order to be awakened!</span>")
		revert_cast()
		return
	if(hivehost.isintegrating)
		to_chat(user, "<span class='warning'>We are already awakening a vessel!</span>")
		revert_cast()
		return
	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>We must tighten our grip to be able to awaken their mind!</span>")
		revert_cast()
		return
	if(IS_HIVEHOST(target) || IS_WOKEVESSEL(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>Complex mental barriers protect [target.name]'s mind.</span>")
		revert_cast()
		return
	hivehost.isintegrating = TRUE

	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>We tap into our vessel's mind. We must stay still..</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] places their hands on [target]'s head!</span>", "<span class='notice'>We place our hands on their temple</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] begins to look frantic!</span>", "<span class='notice'>We begin to override [target]'s consciousness with our own.</span>")
				to_chat(target, "<span class='userdanger'>Your consciousness beings to waver!</span>")

		if(!do_after(user, 2 SECONDS, target))
			to_chat(user, "<span class='warning'>Our awakening of [target] has been interrupted!</span>")
			hivehost.isintegrating = FALSE
			return
	hivehost.isintegrating = FALSE
	var/datum/antagonist/hivevessel/V = new /datum/antagonist/hivevessel()
	hivehost.avessels += target.mind
	V.master = hivehost
	V.hiveID = hivehost.hiveID
	target.mind.add_antag_datum(V)
	var/O = "Obey and Protect your Hive Host, [user]"
	var/datum/objective/brainwashing/objective = new(O)
	V.objectives += objective
	log_objective(V, objective.explanation_text)
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>This vessel is now an extension of our will.</span>")
	if(hivehost.dominant)
		V.glow = hivehost.glow
		target.add_overlay(hivehost.glow)
