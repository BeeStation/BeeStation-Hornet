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

	if(HAS_TRAIT(target, TRAIT_HIVE_BURNT))
		to_chat(user, "<span class='notice'>This mind was ridden bare and holds no value anymore.</span>")
		return
	if(target.mind && target.client && target.stat != DEAD)
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
						if(ignore_mindshield)
							to_chat(user, "<span class='warning'>We are briefly exhausted by the effort required by our enhanced assimilation abilities.</span>")
							user.Immobilize(50)
							SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
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
		if(target.mind in (GLOB.security_positions || GLOB.command_positions)) //Doesn't work on sec or command for balance reasons
			to_chat(user, "<span class='warning'>A subconciously trained response barely protects [target.name]'s mind.</span>")
			to_chat(target, "<span class='assimilator'>Powerful mental attacks strike out against us, our training allows us to barely overcome it.</span>")
			return
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
			return
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
	desc = "We attack any foreign presences in the target mind keeping them only for ourselves. Takes longer if the target is not in our hive."
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
				var/mob/living/real_enemy = (M.current.get_real_hivehost())
				enemies += real_enemy
				enemy.remove_from_hive(target)
				if(M.current.is_real_hivehost())
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
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. They have heard our call. They know we are coming.</span>")
			to_chat(user, "<span class='assimilator'>This vision has provided us insight on the mental lay, allowing us to track our foes.</span>")
			hive.searchcharge += 2
		else
			to_chat(user, "<span class='notice'>We strike into the inner depths of their mind and strike at nothing, no enemies lurk inside this mind.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/targeted/hive_integrate
	name = "Integrate"
	desc = "Allows us to syphon the psionic energy from a Host withing our grasp."
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
				user.visible_message("<span class='warning'>[user] places their hands on [target]'s head!</span>", "<span class='notice'>We place our hands on their temple.</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] seems to be falling unconcious</span>", "<span class='notice'>We begin to fragment [target]'s mind.</span>")
				to_chat(target, "<span class='userdanger'>Your conciousness beings to waver!</span>")

		if(!do_mob(user, target, 150))
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
	to_chat(user,"<span class='assimilator'>Thanks to this new strenght we may awaken an additional vessel..</span>")
	hivehost.check_powers()

/obj/effect/proc_holder/spell/self/hive_loyal
	name = "Concentrated Infiltration"
	desc = "We prepare for a focused attack on a mind, penetrating mindshield technology, the mindshield will still be present after the attack (toggle)."
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
	to_chat(user, "<span class='notice'>We [active?"let our minds rest and ease up on our concentration.":"prepare to spear through mindshielding technology!"]</span>")
	active = !active
	if(active)
		revert_cast()

/obj/effect/proc_holder/spell/targeted/forcewall/hive
	name = "Telekinetic Field"
	desc = "Our psionic powers form a barrier around us in the physical world that only we can pass through."
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
	name = "Telepathic Currents"
	desc = "We may communicate with our rivals for ceasefires, trickery or betrayal."
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
		if(is_hivehost(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")


/obj/effect/proc_holder/spell/target_hive/hive_compell
	name = "Compell"
	desc = "We forcefully insert a directive into a vessels mind for a limited time, they'll obey with anything short of suicide."
	action_icon_state = "empower"

	charge_max = 1800

/obj/effect/proc_holder/spell/target_hive/hive_compell/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	var/directive = stripped_input(user, "What objective do you want to give that vessel?", "Objective")

	if(target.mind && target.client && target.stat != DEAD)
		if((!HAS_TRAIT(target, TRAIT_MINDSHIELD)) && !istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			if(!is_hivehost(target))
				target.hive_weak_awaken(directive)
			else
				to_chat(user, "<span class='warning'>Complex mental barriers protect [target.name]'s mind.</span>") //So they can't meta the fact this is a host
		else
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
	else
		to_chat(user, "<span class='notice'>We detect no neural activity in this body.</span>")
	if(!success)
		revert_cast()


/obj/effect/proc_holder/spell/targeted/hive_probe
	name = "Probe Mind"
	desc = "We examine a mind for any enemy activity."
	panel = "Hivemind Abilities"
	charge_max = 30
	range = 1
	invocation_type = "none"
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
	if(do_after(user,100,0,target))
		for(var/datum/antagonist/hivemind/enemy as() in GLOB.hivehosts)
			var/datum/mind/M = enemy.owner
			if(!M?.current)
				continue
			if(M.current == user)
				continue
			if(enemy.is_carbon_member(target))
				to_chat(user, "<span class='userdanger'>We have found the vile stain of [enemy.hiveID] within this mind!</span>")
				detected = TRUE
				if(target.mind.has_antag_datum(/datum/antagonist/brainwashed) || target.is_wokevessel())
					to_chat(user, "<span class='assimilator'>Tendrils of control spread through our target's mind their actions are not their own!.</span>")
					return
			if(enemy.owner == M && target.is_real_hivehost())
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
		if(!detected)
			to_chat(user, "<span class='notice'>Untroubled waters meet our tentative search,there is nothing out of the ordinary here.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()


/obj/effect/proc_holder/spell/targeted/hive_thrall
	name = "Awaken Vessel"
	desc = "We awaken one of our vessels, permanently turning them into an extension of our will, we can only sustain a limited ammount of awakened vessels increasing with integrations."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = "none"
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
	if(hivehost.avessels.len >= hivehost.avessel_limit)
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
	hivehost.isintegrating = TRUE

	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, "<span class='notice'>We tap into our vessel's mind.We must stay still..</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] places their hands on [target]'s head!</span>", "<span class='notice'>We place our hands on their temple</span>")
			if(3)
				user.visible_message("<span class='danger'>[target] begins to look frantic!</span>", "<span class='notice'>We begin to override [target]'s conciousness with our own.</span>")
				to_chat(target, "<span class='userdanger'>Your conciousness beings to waver!</span>")

		if(!do_mob(user, target, 10))
			to_chat(user, "<span class='warning'>Our awakening of [target] has been interrupted!</span>")
			hivehost.isintegrating = FALSE
			return
	hivehost.isintegrating = FALSE
	var/datum/antagonist/hivevessel/V = new /datum/antagonist/hivevessel()
	hivehost.avessels += target.mind
	V.master = hivehost
	V.hiveID = hivehost.hiveID
	target.mind.add_antag_datum(V)
	flash_color(user, flash_color="#800080", flash_time=10)
	to_chat(user,"<span class='assimilator'>This vessel is now an extension of our will.</span>")
	if(hivehost.unlocked_dominance)
		target.add_overlay(hivehost.glow)

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
		if(is_hivehost(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")


/obj/effect/proc_holder/spell/target_hive/hive_shatter
	name = "Crush Protections"
	desc = "We destroy any Mindshield implants a vesssel might have, granting us further control over their mind."
	action_icon_state = "shatter"

	charge_max = 1800

/obj/effect/proc_holder/spell/target_hive/hive_shatter/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		if(!do_after(user,200,0))
			for(var/obj/item/implant/mindshield/M in target.implants)
				to_chat(user, "<span class='notice'>We shatter their mental protections!</span>")
				to_chat(target, "<span class='assimilator'>We feel a pang of pain course through our head!</span>")
				flash_color(target, flash_color="#800080", flash_time=10)
				qdel(M)

		else
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
	else
		to_chat(user, "<span class='warning'>No protections are present in [target]'s mind.</span>")
	if(!success)
		revert_cast()
/obj/effect/proc_holder/spell/targeted/hive_rally
	name = "Hive Rythms"
	desc = "We send out a burst of psionic energy, all our vessels will feel exhausted yet us and awakened vessels near us will be invigorated."
	panel = "Hivemind Abilities"
	charge_max = 3000
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	include_user = 1
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "rally"

/obj/effect/proc_holder/spell/targeted/hive_rally/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!targets)
		to_chat(user, "<span class='notice'>Nobody is in sight, it'd be a waste to do that now.</span>")
		revert_cast()
		return
	var/list/victims = list()
	for(var/mob/living/target in targets)
		if(target.is_real_hivehost())
			victims += target
		var/datum/mind/mind = target.mind
		if(mind in hive.avessels)
			victims += target
		flash_color(target, flash_color="#800080", flash_time=10)
	for(var/mob/living/carbon/affected in victims)
		to_chat(affected, "<span class='assimilator'>Otherwordly strength flows through us!</span>")
		affected.SetSleeping(0)
		affected.SetUnconscious(0)
		affected.SetStun(0)
		affected.SetKnockdown(0)
		affected.SetImmobilized(0)
		affected.SetParalyzed(0)
		affected.adjustStaminaLoss(-200)


/obj/effect/proc_holder/spell/self/hive_dominance
	name = "One Mind"
	desc = "Our true power... finally within reach."
	panel = "Hivemind Abilities"
	charge_type = "charges"
	charge_max = 1
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "assim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_dominance/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	hive.glow = mutable_appearance('icons/effects/hivemind.dmi', "awoken", -BODY_BEHIND_LAYER)
	for(var/datum/antagonist/hivevessel/vessel in hive.avessels)
		var/mob/living/carbon/C = vessel.owner?.current
		C.Jitter(15)
		C.Unconscious(150)
		to_chat(C, "<span class='boldwarning'>Something's wrong...</span>")
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>...your memories are becoming fuzzy.</span>"), 45)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>You try to remember who you are...</span>"), 90)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='assimilator'>There is no you...</span>"), 110)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='bigassimilator'>...there is only us.</span>"), 130)
		addtimer(CALLBACK(C, /atom/proc/add_overlay, hive.glow), 150)

	for(var/datum/antagonist/hivemind/enemy in GLOB.hivehosts)
		if(enemy.owner)
			enemy.owner.RemoveSpell(new/obj/effect/proc_holder/spell/self/hive_dominance)
			var/mob/living/carbon/C = enemy.owner?.current
			if(!enemy.hiveID == hive.hiveID)
				to_chat(C, "<span class='boldwarning'>Something's wrong...</span>")
				addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>...a new presence.</span>"), 45)
				addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>It feels overwhelming...</span>"), 90)
				addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='assimilator'>It can't be!</span>"), 110)
				addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='bigassimilator'>Get away, run!</span>"), 130)
	sound_to_playing_players('sound/effects/one_mind.ogg')
	addtimer(CALLBACK(user, /atom/proc/add_overlay, hive.glow), 150)
	addtimer(CALLBACK(hive, /datum/antagonist/hivemind/proc/dominance), 150)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/send_to_playing_players, "<span class='bigassimilator'>THE ONE MIND RISES</span>"), 150)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/sound_to_playing_players, 'sound/effects/magic.ogg'), 150)





