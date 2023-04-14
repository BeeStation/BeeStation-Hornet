/obj/effect/proc_holder/spell/targeted/hive_hack
	name = "Network Invasion"
	desc = "We attack any foreign presences in the target mind keeping them only for ourselves. Takes longer if the target is not in our hive. Will grant us a tracking charge if successful."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	invocation_type = INVOCATION_NONE
	clothes_req = 0
	max_targets = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "hack"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_hack/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/target = targets[1]
	var/in_hive = hive.is_carbon_member(target)
	var/list/enemies = list()

	to_chat(user, "<span class='notice'>We begin probing [target.name]'s mind!</span>")
	if(do_after(user, 50, target, timed_action_flags = IGNORE_HELD_ITEM))
		if(!in_hive)
			to_chat(user, "<span class='notice'>Their mind slowly opens up to us.</span>")
			if(!do_after(user, 75, target, timed_action_flags = IGNORE_HELD_ITEM))
				to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
				revert_cast()
				return
		for(var/datum/antagonist/hivemind/enemy as() in GLOB.hivehosts)
			var/datum/mind/M = enemy.owner
			if(!M?.current)
				continue
			if(M.current == user)
				continue
			if(enemy.is_carbon_member(target))
				var/mob/living/real_enemy = (M.current)
				enemies += real_enemy
				enemy.remove_from_hive(target)
				to_chat(real_enemy, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")

			if(enemy.owner == M && IS_HIVEHOST(target))
				var/atom/throwtarget
				var/datum/antagonist/hivemind/hivetarget = target.mind.has_antag_datum(/datum/antagonist/hivemind)
				throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(user, src)))
				SEND_SOUND(user, sound(pick('sound/hallucinations/turn_around1.ogg','sound/hallucinations/turn_around2.ogg'),0,1,50))
				flash_color(user, flash_color="#800080", flash_time=10)
				user.Paralyze(10)
				user.throw_at(throwtarget, 5, 1,src)
				to_chat(user, "<span class='userdanger'>A sudden surge of psionic energy, a recognizable presence, this is the host of [hivetarget.hiveID]</span>")
				return
		if(enemies.len)
			hive.remove_hive_overlay_probe(target)
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. They have heard our call. They know we are coming.</span>")
			to_chat(user, "<span class='assimilator'>This vision has provided us insight on the mental lay, allowing us to track our foes.</span>")
			hive.searchcharge += 3
		else
			to_chat(user, "<span class='notice'>We delve into the inner depths of their mind and strike at nothing, no enemies lurk inside this mind.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()
