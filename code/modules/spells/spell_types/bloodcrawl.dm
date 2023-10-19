/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood Crawl"
	desc = "Use pools of blood to phase out of existence."
	charge_max = 300 SECONDS
	charge_counter = 300 SECONDS
	clothes_req = FALSE
	//If you couldn't cast this while phased, you'd have a problem
	phase_allowed = TRUE
	selection_type = "range"
	range = 1
	cooldown_min = 300 SECONDS
	overlay = null
	recharging = TRUE
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_demon"
	var/phased = FALSE

/obj/effect/proc_holder/spell/bloodcrawl/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in view(range, get_turf(user)))
		if(target.can_bloodcrawl_in())
			perform(target)
			return
	to_chat(user, "<span class='warning'>There must be a nearby source of blood!</span>")

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(phased)
			if(user.phasein(target))
				phased = FALSE
		else
			if(user.phaseout(target))
				phased = TRUE
		start_recharge()
		return
	start_recharge()
	to_chat(user, "<span class='warning'>You are unable to blood crawl!</span>")

/obj/effect/proc_holder/spell/bloodcrawl/husk
	charge_type = "recharge"
	charge_max = 300 SECONDS
	charge_counter = 300 SECONDS
	cooldown_min = 50
	still_recharging_msg = "You are still reforming."
