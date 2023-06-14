/obj/effect/proc_holder/spell/targeted/hive_integrate
	name = "Integrate"
	desc = "Allows us to syphon the psionic energy from a Host within our grasp."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = INVOCATION_NONE
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "reclaim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_integrate/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/human/target = user.pulling
	if(!target)
		to_chat(user, "<span class='warning'>We must be grabbing a creature to integrate them!</span>")
		hivehost.isintegrating = FALSE
		revert_cast()
		return
	if(!IS_HIVEHOST(target))
		to_chat(user, "<span class='warning'>Their mind is worthless to us!</span>")
		revert_cast()
		return
	if(hivehost.isintegrating)
		to_chat(user, "<span class='warning'>We are already integrating a mind!</span>")
		revert_cast()
		return
	if(user.grab_state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to integrate their mind!</span>")
		revert_cast()
		return
	hivehost.isintegrating = TRUE

	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>This shining mind is with reach.We must stay still..</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] places their hands on [target]'s head!</span>", "<span class='notice'>We place our hands on their temple.</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] seems to be falling unconscious</span>", "<span class='notice'>We begin to fragment [target]'s mind.</span>")
				to_chat(target, "<span class='userdanger'>Your consciousness begin to waver!</span>")

		if(!do_after(user, 15 SECONDS, target))
			to_chat(user, "<span class='warning'>Our integration of [target] has been interrupted!</span>")
			hivehost.isintegrating = FALSE
			return
	to_chat(target, "<span class='userdanger'>You mind is shattered!</span>")
	hivehost.isintegrating = FALSE
	var/datum/antagonist/hivemind/enemy = target.mind.has_antag_datum(/datum/antagonist/hivemind)
	enemy.destroy_hive() //Just in case
	target.gib()
	hivehost.size_mod += 5
	hivehost.avessel_limit += 1
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>We have reclaimed what gifts weaker minds were squandering and gain ever more insight on our psionic abilities.</span>")
	to_chat(user,"<span class='assimilator'>Thanks to this new strength we may awaken an additional vessel..</span>")
	hivehost.check_powers()
