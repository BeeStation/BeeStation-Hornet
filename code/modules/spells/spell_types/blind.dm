/obj/effect/proc_holder/spell/targeted/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."
	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	cooldown_min = 50 //12 deciseconds reduction per rank
	ranged_mousepointer = 'icons/effects/blind_target.dmi'
	action_icon_state = "blind"
	range = 7
	selection_type = "range"
	var/duration = 300 //30 seconds
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))


/obj/effect/proc_holder/spell/targeted/blind/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, span_notice("No target found in range."))
		revert_cast()
		return
	
	var/mob/living/carbon/target = targets[1]

	if(!compatible_mobs_typecache[target.type])
		to_chat(user, span_notice("You are unable to curse [target] with blindness!"))
		revert_cast()
		return
	
	if(!(target in oview(range)))
		to_chat(user, span_notice("[target.p_theyre(TRUE)] too far away!"))
		revert_cast()
		return
	
	if(target.anti_magic_check() || HAS_TRAIT(target, TRAIT_WARDED))
		to_chat(user, span_warning("The spell had no effect!"))
		target.visible_message(span_danger("[target]'s eyes darken, but instantly turn back to their regular color, leaving [target] unharmed!"), \
						   span_danger("Your eyes hurt for a moment, but the blindness is repulsed by your anti-magic protection!"))
		return
	
	target.visible_message(span_danger("[target]'s eyes darken as black smoke starts coming out of them!"), \
						   span_danger("Your eyes hurt as they start smoking, you panic as you realise you're blind!"))
	target.emote("scream")
	target.become_blind(MAGIC_BLIND)
	addtimer(CALLBACK(src, .proc/cure_blindness, target), duration)

/obj/effect/proc_holder/spell/targeted/blind/proc/cure_blindness(mob/living/L)
	L.cure_blind(MAGIC_BLIND)
