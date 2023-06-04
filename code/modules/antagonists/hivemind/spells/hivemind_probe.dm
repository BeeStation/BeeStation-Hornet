/obj/effect/proc_holder/spell/targeted/hive_probe
	name = "Probe Mind"
	desc = "We examine a mind for any enemy activity."
	panel = "Hivemind Abilities"
	charge_max = 30
	range = 1
	invocation_type = INVOCATION_NONE
	clothes_req = 0
	max_targets = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "probe"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_probe/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/target = targets[1]
	var/detected


	to_chat(user, "<span class='notice'>We begin probing [target.name]'s mind!</span>")
	if(do_after(user, 15, target, timed_action_flags = IGNORE_HELD_ITEM))
		for(var/datum/antagonist/hivemind/enemy as() in GLOB.hivehosts)
			var/datum/mind/M = enemy.owner
			if(!M?.current)
				continue
			if(M.current == user)
				continue
			if(enemy.owner == M && IS_HIVEHOST(target))
				detected = TRUE
				var/atom/throwtarget
				var/datum/antagonist/hivemind/hivetarget = target.mind.has_antag_datum(/datum/antagonist/hivemind)
				throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(user, src)))
				SEND_SOUND(user, sound(pick('sound/hallucinations/turn_around1.ogg','sound/hallucinations/turn_around2.ogg'),0,1,50))
				flash_color(user, flash_color="#800080", flash_time=10)
				user.Paralyze(10)
				user.throw_at(throwtarget, 5, 1,src)
				to_chat(user, "<span class='userdanger'>A sudden surge of psionic energy, a recognizable presence, this is the host of [hivetarget.hiveID]!</span>")
				return
			if(enemy.is_carbon_member(target))
				hive.add_hive_overlay_probe(target)
				to_chat(user, "<span class='userdanger'>We have found the vile stain of [enemy.hiveID] within this mind!</span>")
				detected = TRUE
				if(target.mind.has_antag_datum(/datum/antagonist/brainwashed) || IS_WOKEVESSEL(target))
					to_chat(user, "<span class='assimilator'>Our target is being controlled, their actions are not their own!.</span>")
					return
		if(!detected)
			to_chat(user, "<span class='notice'>Untroubled waters meet our tentative search, there is nothing out of the ordinary here.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()
