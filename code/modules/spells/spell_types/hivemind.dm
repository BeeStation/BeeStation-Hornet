/obj/effect/proc_holder/spell/target_hive
	panel = "Hivemind Abilities"
	invocation_type = "none"
	selection_type = "range"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "spell_default"
	clothes_req = 0
	human_req = 1
	antimagic_allowed = TRUE
	range = 0 //SNOWFLAKE, 0 is unlimited for target_external=0 spells
	var/target_external = 0 //Whether or not we select targets inside or outside of the hive


/obj/effect/proc_holder/spell/target_hive/choose_targets(mob/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/list/possible_targets = list()
	var/list/targets = list()

	if(target_external)
		for(var/mob/living/carbon/H in view_or_range(range, user, selection_type))
			if(user == H)
				continue
			if(!can_target(H))
				continue
			if(!hive.is_carbon_member(H))
				possible_targets += H
	else
		possible_targets = hive.get_carbon_members()
		if(range)
			possible_targets &= view_or_range(range, user, selection_type)

	var/mob/living/carbon/human/H = input("Choose the target for the spell.", "Targeting") as null|mob in possible_targets
	if(!H)
		revert_cast()
		return
	targets += H
	perform(targets,user=user)

/obj/effect/proc_holder/spell/target_hive/hive_add
	name = "Assimilate Vessel"
	desc = "We silently add an unsuspecting target to the hive."
	selection_type = "view"
	action_icon_state = "add"

	charge_max = 50
	range = 7
	target_external = 1
	var/ignore_mindshield = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_add/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE

	if(target.stat != DEAD)
		if((!HAS_TRAIT(target, TRAIT_MINDSHIELD) || ignore_mindshield) && !istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			if(HAS_TRAIT(target, TRAIT_MINDSHIELD) && ignore_mindshield)
				to_chat(user, "<span class='notice'>We bruteforce our way past the mental barriers of [target.name] and begin linking our minds!</span>")
			else
				to_chat(user, "<span class='notice'>We begin linking our mind with [target.name]!</span>")
			if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && (user in viewers(range, target)))
				if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && (user in viewers(range, target)))
					if((!HAS_TRAIT(target, TRAIT_MINDSHIELD) || ignore_mindshield) && (user in viewers(range, target)))
						to_chat(user, "<span class='notice'>[target.name] was added to the Hive!</span>")
						success = TRUE
						hive.add_to_hive(target)
						hive.threat_level = max(0, hive.threat_level-0.1)
						if(ignore_mindshield)
							to_chat(user, "<span class='warning'>We are briefly exhausted by the effort required by our enhanced assimilation abilities.</span>")
							user.Immobilize(50)
							SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
							for(var/obj/item/implant/mindshield/M in target.implants)
								qdel(M)
					else
						to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
				else
					to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
			else
				to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
		else
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
	else
		to_chat(user, "<span class='notice'>We detect no neural activity in this body.</span>")
	if(!success)
		revert_cast()

/obj/effect/proc_holder/spell/target_hive/hive_remove
	name = "Release Vessel"
	desc = "We silently remove a nearby target from the hive. We must be close to their body to do so."
	selection_type = "view"
	action_icon_state = "remove"

	charge_max = 50
	range = 7

/obj/effect/proc_holder/spell/target_hive/hive_remove/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]

	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/datum/mind/M = target.mind
	if(!M)
		revert_cast()
		return
	hive.remove_from_hive(M)
	hive.calc_size()
	hive.threat_level += 0.1
	to_chat(user, "<span class='notice'>We remove [target.name] from the hive</span>")

/obj/effect/proc_holder/spell/target_hive/hive_see
	name = "Hive Vision"
	desc = "We use the eyes of one of our vessels. Use again to look through our own eyes once more."
	action_icon_state = "see"
	var/mob/living/carbon/vessel
	var/mob/living/host //Didn't really have any other way to auto-reset the perspective if the other mob got qdeled

	charge_max = 20

/obj/effect/proc_holder/spell/target_hive/hive_see/on_lose(mob/living/user)
	user.reset_perspective()
	user.clear_fullscreen("hive_eyes")

/obj/effect/proc_holder/spell/target_hive/hive_see/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		if(vessel)
			vessel.apply_status_effect(STATUS_EFFECT_BUGGED, user)
			user.reset_perspective(vessel)
			active = TRUE
			host = user
			user.overlay_fullscreen("hive_eyes", /atom/movable/screen/fullscreen/hive_eyes)
		revert_cast()
	else
		vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
		user.reset_perspective()
		user.clear_fullscreen("hive_eyes")
		active = FALSE
		revert_cast()

/obj/effect/proc_holder/spell/target_hive/hive_see/process()
	if(active && (!vessel || !is_hivemember(vessel) || QDELETED(vessel)))
		to_chat(host, "<span class='warning'>Our vessel is one of us no more!</span>")
		host.reset_perspective()
		host.clear_fullscreen("hive_eyes")
		active = FALSE
		if(!QDELETED(vessel))
			vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
	..()

/obj/effect/proc_holder/spell/target_hive/hive_see/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(,user)

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
	if(do_after(user,30,0,user))
		var/power = 120-get_dist(user, target)
		if(!is_hivehost(target))
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


/obj/effect/proc_holder/spell/self/hive_scan
	name = "Psychoreception"
	desc = "We release a pulse to receive information on any enemies we have previously located via Network Invasion, as well as those currently tracking us."
	panel = "Hivemind Abilities"
	charge_max = 1800
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "scan"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_scan/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/message
	var/distance

	for(var/datum/status_effect/hive_track/track in user.status_effects)
		var/mob/living/L = track.tracked_by
		if(!L)
			continue
		if(!do_after(user,5,0,user))
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
			break
		distance = get_dist(user, L)
		message = "[(L.is_real_hivehost()) ? "Someone": "A hivemind host"] tracking us"
		if(user.get_virtual_z_level() != L.get_virtual_z_level() || L.stat == DEAD)
			message += " could not be found."
		else
			switch(distance)
				if(0 to 2)
					message += " is right next to us!"
				if(2 to 14)
					message += " is nearby."
				if(14 to 28)
					message += " isn't too far away."
				if(28 to INFINITY)
					message += " is quite far away."
		to_chat(user, "<span class='assimilator'>[message]</span>")
	for(var/datum/antagonist/hivemind/enemy in hive.individual_track_bonus)
		if(!do_after(user,5,0,user))
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
			break
		var/mob/living/carbon/C = enemy.owner?.current
		if(!C)
			continue
		var/mob/living/real_enemy = C.get_real_hivehost()
		distance = get_dist(user, real_enemy)
		message = "A host that we can track for [(hive.individual_track_bonus[enemy])/10] extra seconds"
		if(user.get_virtual_z_level() != real_enemy.get_virtual_z_level() || real_enemy.stat == DEAD)
			message += " could not be found."
		else
			switch(distance)
				if(0 to 2)
					message += " is right next to us!"
				if(2 to 14)
					if(enemy.get_threat_multiplier() >= 0.85 && distance <= 7)
						message += " is in this very room!"
					else
						message += " is nearby."
				if(14 to 28)
					message += " isn't too far away."
				if(28 to INFINITY)
					message += " is quite far away."
		to_chat(user, "<span class='assimilator'>[message]</span>")

/obj/effect/proc_holder/spell/self/hive_drain
	name = "Repair Protocol"
	desc = "Our many vessels sacrifice a small portion of their mind's vitality to cure us of our physical and mental ailments."

	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "drain"
	human_req = 1
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_drain/cast(mob/living/carbon/human/user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		return
	var/iterations = 0
	var/list/carbon_members = hive.get_carbon_members()
	if(!carbon_members.len)
		return
	if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss() && !user.getOrganLoss(ORGAN_SLOT_BRAIN))
		to_chat(user, "<span class='notice'>We cannot heal ourselves any more with this power!</span>")
		revert_cast()
	to_chat(user, "<span class='notice'>We begin siphoning power from our many vessels!</span>")
	while(iterations < 7)
		var/mob/living/carbon/target = pick(carbon_members)
		if(!do_after(user,15,0,user))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		if(!target)
			to_chat(user, "<span class='warning'>We have run out of vessels to drain.</span>")
			break
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		if(user.getBruteLoss() > user.getFireLoss())
			user.heal_ordered_damage(5, list(CLONE, BRUTE, BURN))
		else
			user.heal_ordered_damage(5, list(CLONE, BURN, BRUTE))
		if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss()) //If we don't have any of these, stop looping
			to_chat(user, "<span class='warning'>We finish our healing.</span>")
			break
		iterations++
	user.setOrganLoss(ORGAN_SLOT_BRAIN, 0)


/mob/living/passenger
	name = "mind control victim"
	real_name = "unknown conscience"

/mob/living/passenger/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You find yourself unable to speak, you aren't in control of your body!</span>")
	return FALSE

/mob/living/passenger/emote(act, m_type = null, message = null, intentional = FALSE)
	to_chat(src, "<span class='warning'>You find yourself unable to emote, you aren't in control of your body!</span>")
	return

/mob/living/passenger/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mods)
	return

/obj/effect/proc_holder/spell/targeted/induce_panic
	name = "Induce Panic"
	desc = "We unleash a burst of psionic energy, inducing a debilitating fear in those around us and reducing their combat readiness. We can also briefly affect silicon-based life with this burst."
	panel = "Hivemind Abilities"
	charge_max = 900
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "panic"

/obj/effect/proc_holder/spell/targeted/induce_panic/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat == DEAD)
			continue
		target.Jitter(14)
		target.apply_damage(35 + rand(0,15), STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
		if(target.is_real_hivehost())
			continue
		if(prob(20))
			var/text = pick(";HELP!","I'm losing control of the situation!!","Get me outta here!")
			target.say(text, forced = "panic")
		if(prob(1))
			SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))
		var/effect = rand(1,4)
		switch(effect)
			if(1)
				to_chat(target, "<span class='userdanger'>You panic and drop everything to the ground!</span>")
				target.drop_all_held_items()
			if(2)
				to_chat(target, "<span class='userdanger'>You panic and flail around!</span>")
				target.click_random_mob()
				addtimer(CALLBACK(target, "click_random_mob"), 5)
				addtimer(CALLBACK(target, "click_random_mob"), 10)
				addtimer(CALLBACK(target, "click_random_mob"), 15)
				addtimer(CALLBACK(target, "click_random_mob"), 20)
				addtimer(CALLBACK(target, "Stun", 30), 25)
				target.confused += 10
			if(3)
				to_chat(target, "<span class='userdanger'>You freeze up in fear!</span>")
				target.Stun(70)
			if(4)
				to_chat(target, "<span class='userdanger'>You feel nauseous as dread washes over you!</span>")
				target.Dizzy(15)
				target.apply_damage(30, STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
				target.hallucination += 45

	for(var/mob/living/silicon/target in targets)
		target.Unconscious(50)

/obj/effect/proc_holder/spell/targeted/hive_hack
	name = "Network Invasion"
	desc = "We probe the mind of an adjacent target and extract valuable information on any enemy hives they may belong to. Takes longer if the target is not in our hive."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	invocation_type = "none"
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
	if(do_after(user,100,0,target))
		if(!in_hive)
			to_chat(user, "<span class='notice'>Their mind slowly opens up to us.</span>")
			if(!do_after(user,200,0,target))
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
				hive.add_track_bonus(enemy, TRACKER_BONUS_LARGE)
				var/mob/living/real_enemy = (M.current.get_real_hivehost())
				enemies += real_enemy
				enemy.remove_from_hive(target)
				real_enemy.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, user, hive.get_track_bonus(enemy))
				if(M.current.is_real_hivehost()) //If they were using mind control, too bad
					real_enemy.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
					target.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_enemy, enemy.get_track_bonus(hive))
					to_chat(real_enemy, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")

			if(enemy.owner == M && target.is_real_hivehost())
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
			hive.track_bonus += TRACKER_BONUS_SMALL
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. They have heard our call. They know we are coming.</span>")
			to_chat(user, "<span class='assimilator'>This vision has provided us insight on our very nature, improving our sensory abilities, particularly against the hives this vessel belonged to.</span>")
			user.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		else
			to_chat(user, "<span class='notice'>We peer into the inner depths of their mind and see nothing, no enemies lurk inside this mind.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/targeted/hive_integrate
	name = "Integrate"
	desc = "Allows us to syphon the psionic energy from a Host withing our grasp"
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = "none"
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
	if(!is_hivehost(target))
		to_chat(user, "<span class='warning'>Their mind is worthless to us!.</span>")
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
				user.visible_message("<span class='warning'>[user] places their hands on [target]'s head!</span>", "<span class='notice'>We place our hands on their temple</span>")
			if(3)
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>", "<span class='notice'>We stab [target] with the proboscis.</span>")
				to_chat(target, "<span class='userdanger'>Your conciousness beings to waver!</span>")

		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>Our integration of [target] has been interrupted!</span>")
			hivehost.isintegrating = 0
			return
	to_chat(target, "<span class='userdanger'>You mind is shattered!</span>")
	target.gib()
	hivehost.track_bonus += TRACKER_BONUS_LARGE
	hivehost.size_mod += 5
	hivehost.threat_level += 1
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>We have reclaimed what gifts weaker minds were squandering and gain ever more insight on our psionic abilities.</span>")
	to_chat(user,"<span class='assimilator'>Thanks to this new knowledge, our sensory powers last a great deal longer.</span>")
	hivehost.check_powers()

/obj/effect/proc_holder/spell/self/hive_loyal
	name = "Bruteforce"
	desc = "Our ability to assimilate is boosted at the cost of, allowing us to crush the technology shielding the minds of Security and Command personnel and assimilate them. This power comes at a small price, and we will be immobilized for a few seconds after assimilation."
	panel = "Hivemind Abilities"
	charge_max = 600
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "loyal"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_loyal/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/obj/effect/proc_holder/spell/target_hive/hive_add/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_add) in user.mind.spell_list
	if(!the_spell)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE5</span>")
		return
	the_spell.ignore_mindshield = !active
	to_chat(user, "<span class='notice'>We [active?"let our minds rest and cancel our crushing power.":"prepare to crush mindshielding technology!"]</span>")
	active = !active
	if(active)
		revert_cast()

/obj/effect/proc_holder/spell/targeted/forcewall/hive
	name = "Telekinetic Field"
	desc = "Our psionic powers form a barrier around us in the phsyical world that only we can pass through."
	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	human_req = 1
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "forcewall"
	range = -1
	include_user = 1
	antimagic_allowed = TRUE
	wall_type = /obj/effect/forcefield/wizard/hive
	var/wall_type_b = /obj/effect/forcefield/wizard/hive/invis

/obj/effect/proc_holder/spell/targeted/forcewall/hive/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user), null, user)
	for(var/dir in GLOB.alldirs)
		new wall_type_b(get_step(user, dir), null, user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(hive)
		hive.threat_level += 0.5

/obj/effect/forcefield/wizard/hive
	name = "Telekinetic Field"
	desc = "You think, therefore it is."
	timeleft = 150
	pixel_x = -32 //Centres the 96x96 sprite
	pixel_y = -32
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hive_shield"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/forcefield/wizard/hive/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover == wizard)
		return TRUE
	return FALSE

/obj/effect/forcefield/wizard/hive/invis
	icon = null
	icon_state = null
	pixel_x = 0
	pixel_y = 0
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/proc_holder/spell/self/hive_comms
	name = "Hive Communication"
	desc = "Now that we are free we may finally share our thoughts with our many bretheren."
	panel = "Hivemind Abilities"
	charge_max = 100
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "comms"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_comms/cast(mob/living/user = usr)
	var/message = stripped_input(user, "What do you want to say?", "Hive Communication")
	var/datum/antagonist/hivemind/hivehost = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hivehost)
		return
	if(!message)
		return
	var/title = "Hive"
	var/my_message = "<span class='changeling'><b>[title] [hivehost.hiveID]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(is_hivehost(M) || is_hivemember(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")
