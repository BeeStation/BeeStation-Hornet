/obj/effect/proc_holder/spell/targeted/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = INVOCATION_WHISPER
	cooldown_min = 50 //12 deciseconds reduction per rank
	ranged_mousepointer = 'icons/effects/blind_target.dmi'
	action_icon_state = "blind"
	range = 7
	selection_type = "range"
	var/duration = 300 //30 seconds
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))


/obj/effect/proc_holder/spell/targeted/blind/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/carbon/target = targets[1]

	if(!compatible_mobs_typecache[target.type])
		to_chat(user, "<span class='notice'>You are unable to curse [target] with blindness!</span>")
		revert_cast()
		return

	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>[target.p_theyre(TRUE)] too far away!</span>")
		revert_cast()
		return

	if(target.anti_magic_check() || HAS_TRAIT(target, TRAIT_WARDED))
		to_chat(user, "<span class='warning'>The spell had no effect!</span>")
		target.visible_message("<span class='danger'>[target]'s eyes darken, but instantly turn back to their regular color, leaving [target] unharmed!</span>", \
						   "<span class='danger'>Your eyes hurt for a moment, but the blindness is repulsed by your anti-magic protection!</span>")
		return

	target.visible_message("<span class='danger'>[target]'s eyes darken as black smoke starts coming out of them!</span>", \
						   "<span class='danger'>Your eyes hurt as they start smoking, you panic as you realise you're blind!</span>")
	target.emote("scream")
	target.become_blind(MAGIC_BLIND)
	addtimer(CALLBACK(src, PROC_REF(cure_blindness), target), duration)

/obj/effect/proc_holder/spell/targeted/blind/proc/cure_blindness(mob/living/L)
	L.cure_blind(MAGIC_BLIND)
