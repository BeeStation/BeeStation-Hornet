/obj/effect/proc_holder/spell/target_hive/hive_shock
	name = "Neural Shock"
	desc = "After a short charging time, we overload the mind of one of our vessels with psionic energy, rendering them unconscious for a short period of time. This power weakens over distance, but strengthens with hive size."
	action_icon_state = "shock"

	charge_max = 600

/obj/effect/proc_holder/spell/target_hive/hive_shock/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	to_chat(user, "<span class='notice'>We begin increasing the psionic bandwidth between ourself and the vessel!</span>")
	if(do_after(user, 30, user, timed_action_flags = IGNORE_HELD_ITEM))
		if(target.mind.assigned_role in (GLOB.security_positions || GLOB.command_positions)) //Doesn't work on sec or command for balance reasons
			to_chat(user, "<span class='warning'>A subconsciously trained response barely protects [target.name]'s mind.</span>")
			to_chat(target, "<span class='assimilator'>Powerful mental attacks strike out against us, our training allows us to barely overcome it.</span>")
			return
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
			return
		if(!IS_HIVEHOST(target))
			var/power = 120-get_dist(user, target)
			switch(hive.hive_size)
				if(0 to 4)
				if(5 to 9)
					power *= 1.5
				if(10 to 14)
					power *= 2
				if(15 to 19)
					power *= 2.5
				else
					power *= 3
			if(power > 50 && user.get_virtual_z_level() == target.get_virtual_z_level())
				to_chat(user, "<span class='notice'>We have overloaded the vessel for a short time!</span>")
				target.Jitter(round(power/10))
				target.Unconscious(power)
		else
			to_chat(user, "<span class='notice'>The vessel was too far away to be affected!</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()
