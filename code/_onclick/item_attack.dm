/**
  * This is the proc that handles the order of an item_attack.
  *
  * The order of procs called is:
  * * [/atom/proc/tool_act] on the target. If it returns TOOL_ACT_TOOLTYPE_SUCCESS or TOOL_ACT_SIGNAL_BLOCKING, the chain will be stopped.
  * * [/obj/item/proc/pre_attack] on src. If this returns TRUE, the chain will be stopped.
  * * [/atom/proc/attackby] on the target. If it returns TRUE, the chain will be stopped.
  * * [/obj/item/proc/afterattack]. The return value does not matter.
  */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params)
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)

	if(tool_behaviour && (target.tool_act(user, src, tool_behaviour, is_right_clicking) & TOOL_ACT_MELEE_CHAIN_BLOCKING))
		return TRUE

	var/pre_attack_result
	if (is_right_clicking)
		switch (pre_attack_secondary(target, user, params))
			if (SECONDARY_ATTACK_CALL_NORMAL)
				pre_attack_result = pre_attack(target, user, params)
			if (SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if (SECONDARY_ATTACK_CONTINUE_CHAIN)
				// Normal behavior
			else
				CRASH("pre_attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		pre_attack_result = pre_attack(target, user, params)

	if(pre_attack_result)
		return TRUE

	var/attackby_result

	if (is_right_clicking)
		switch (target.attackby_secondary(src, user, params))
			if (SECONDARY_ATTACK_CALL_NORMAL)
				attackby_result = target.attackby(src, user, params)
			if (SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return TRUE
			if (SECONDARY_ATTACK_CONTINUE_CHAIN)
				// Normal behavior
			else
				CRASH("attackby_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")
	else
		attackby_result = target.attackby(src, user, params)

	if (attackby_result)
		return TRUE

	if(QDELETED(src))
		stack_trace("An item got deleted while performing an item attack and did not stop melee_attack_chain.")
		return TRUE
	if(QDELETED(target))
		stack_trace("The target of an item attack got deleted and melee_attack_chain was not stopped.")
		return TRUE

	if (is_right_clicking)
		var/after_attack_secondary_result = afterattack_secondary(target, user, TRUE, params)

		// There's no chain left to continue at this point, so CANCEL_ATTACK_CHAIN and CONTINUE_CHAIN are functionally the same.
		if (after_attack_secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || after_attack_secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
			return TRUE

	return afterattack(target, user, TRUE, params)


/// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	interact(user)

/// Called when the item is in the active hand, and right-clicked. Intended for alternate or opposite functions, such as lowering reagent transfer amount. At the moment, there is no verb or hotkey.
/obj/item/proc/attack_self_secondary(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF_SECONDARY, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE

/**
  * Called on the item before it hits something
  *
  * Arguments:
  * * atom/A - The atom about to be hit
  * * mob/living/user - The mob doing the htting
  * * params - click params such as alt/shift etc
  *
  * See: [/obj/item/proc/melee_attack_chain]
  */
/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE //return TRUE to avoid calling attackby after this proc does stuff

/**
 * Called on the item before it hits something, when right clicking.
 *
 * Arguments:
 * * atom/target - The atom about to be hit
 * * mob/living/user - The mob doing the htting
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/obj/item/proc/pre_attack_secondary(atom/target, mob/living/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK_SECONDARY, target, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/**
  * Called on an object being hit by an item
  *
  * Arguments:
  * * obj/item/attacking_item - The item hitting this atom
  * * mob/user - The wielder of this item
  * * params - click params such as alt/shift etc
  *
  * See: [/obj/item/proc/melee_attack_chain]
  */
/atom/proc/attackby(obj/item/attacking_item, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, attacking_item, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/**
 * Called on an object being right-clicked on by an item
 *
 * Arguments:
 * * obj/item/weapon - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/atom/proc/attackby_secondary(obj/item/weapon, mob/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY_SECONDARY, weapon, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || ((obj_flags & CAN_BE_HIT) && I.attack_atom(src, user, params))

/mob/living/attackby(obj/item/attacking_item, mob/living/user, params)
	if(..())
		return TRUE
	user.changeNext_move(attacking_item.attack_speed)
	return attacking_item.attack(src, user, params)

/mob/living/attackby_secondary(obj/item/weapon, mob/living/user, params)
	var/result = weapon.attack_secondary(src, user, params)

	// Normal attackby updates click cooldown, so we have to make up for it
	if (result != SECONDARY_ATTACK_CALL_NORMAL)
		if(weapon.secondary_attack_speed)
			user.changeNext_move(weapon.secondary_attack_speed)
		else
			user.changeNext_move(weapon.attack_speed)

	return result

/**
 * Called from [/mob/living/proc/attackby]
 *
 * Arguments:
 * * mob/living/target_mob - The mob being hit by this item
 * * mob/living/user - The mob hitting with this item
 * * params - Click params of this attack
 */
/obj/item/proc/attack(mob/living/target_mob, mob/living/user, params)
	var/signal_return = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, target_mob, user, params)
	if(signal_return & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	if(signal_return & COMPONENT_SKIP_ATTACK)
		return

	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, target_mob, user, params)
	SEND_SIGNAL(target_mob, COMSIG_MOB_ITEM_ATTACKBY, user, src)

	var/nonharmfulhit = FALSE

	if(!user.combat_mode && !(item_flags & ISWEAPON))
		nonharmfulhit = TRUE
	for(var/datum/surgery/S in target_mob.surgeries)
		if(S.failed_step)
			nonharmfulhit = FALSE //No freebies, if you fail a surgery step you should hit your patient
			S.failed_step = FALSE //In theory the hit should only happen once, upon failing the step
			break

	if(item_flags & NOBLUDGEON)
		nonharmfulhit = TRUE

	if(force && HAS_TRAIT(user, TRAIT_PACIFISM) && !nonharmfulhit)
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		nonharmfulhit = TRUE

	if(!force || nonharmfulhit)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), TRUE, extrarange = stealthy_audio ? SILENCED_SOUND_EXTRARANGE : -1, falloff_distance = 0)

	target_mob.lastattacker = user.real_name
	target_mob.lastattackerckey = user.ckey

	user.do_attack_animation(target_mob)
	var/time = world.time
	if(nonharmfulhit)
		target_mob.send_item_poke_message(src, user)
		user.time_of_last_poke = time
	else
		user.record_accidental_poking()
		target_mob.attacked_by(src, user)
		target_mob.time_of_last_attack_received = time
		user.time_of_last_attack_dealt = time
		user.check_for_accidental_attack()

	log_combat(user, target_mob, "[nonharmfulhit ? "poked" : "attacked"]", src, "(COMBAT MODE: [uppertext(user.combat_mode)]) (DAMTYPE: [uppertext(damtype)])", important = !nonharmfulhit)
	add_fingerprint(user)

/// The equivalent of [/obj/item/proc/attack] but for alternate attacks, AKA right clicking
/obj/item/proc/attack_secondary(mob/living/victim, mob/living/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SECONDARY, victim, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/// The equivalent of the standard version of [/obj/item/proc/attack] but for non mob targets.
/obj/item/proc/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, attacked_atom, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return
	if(item_flags & NOBLUDGEON)
		return
	user.changeNext_move(attack_speed)
	user.do_attack_animation(attacked_atom)
	attacked_atom.attacked_by(src, user)

/// Called from [/obj/item/proc/attack_atom] and [/obj/item/proc/attack] if the attack succeeds
/atom/proc/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!uses_integrity)
		CRASH("attacked_by() was called on an object that doesnt use integrity!")

	if(!attacking_item.force)
		return

	var/damage = take_damage(attacking_item.force, attacking_item.damtype, MELEE, 1)

	//only witnesses close by and the victim see a hit message.
	user.visible_message("<span class='danger'>[user] hits [src] with [attacking_item][damage ? "." : ", without leaving a mark!"]</span>", \
		"<span class='danger'>You hit [src] with [attacking_item][damage ? "." : ", without leaving a mark!"]</span>", null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "attacked", attacking_item)

/area/attacked_by(obj/item/attacking_item, mob/living/user)
	CRASH("areas are NOT supposed to have attacked_by() called on them!")

/mob/living/attacked_by(obj/item/I, mob/living/user)
	send_item_attack_message(I, user)
	if(!I.force)
		return FALSE
	var/armour_block = run_armor_check(null, MELEE, armour_penetration = I.armour_penetration)
	apply_damage(I.force, I.damtype, blocked = armour_block)
	if(I.damtype == BRUTE && prob(33))
		I.add_mob_blood(src)
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
			user.add_mob_blood(src)
	return TRUE //successful attack

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user, nonharmfulhit = FALSE)
	if(I.force < force_threshold || I.damtype == STAMINA || nonharmfulhit)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), 1, -1)
	else
		return ..()

/mob/living/basic/attacked_by(obj/item/I, mob/living/user)
	if(!attack_threshold_check(I.force, I.damtype, MELEE, FALSE))
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), TRUE, -1)
	else
		return ..()

/**
 * Last proc in the [/obj/item/proc/melee_attack_chain]
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, src, proximity_flag, click_parameters)

/**
 * Called at the end of the attack chain if the user right-clicked.
 *
 * Arguments:
 * * atom/target - The thing that was hit
 * * mob/user - The mob doing the hitting
 * * proximity_flag - is 1 if this afterattack was called on something adjacent, in your square, or on your person.
 * * click_parameters - is the params string from byond [/atom/proc/Click] code, see that documentation.
 */
/obj/item/proc/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK_SECONDARY, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK_SECONDARY, target, src, proximity_flag, click_parameters)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	if(!I.force && !length(I.attack_verb_simple) && !length(I.attack_verb_continuous))
		return
	var/message_verb_continuous = length(I.attack_verb_continuous) ? "[pick(I.attack_verb_continuous)]" : "attacks"
	var/message_verb_simple = length(I.attack_verb_simple) ? "[pick(I.attack_verb_simple)]" : "attack"
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message_spectator = "[src] [message_verb_continuous][message_hit_area] with [I]!"
	var/attack_message_victim = "Something [message_verb_continuous] you[message_hit_area] with [I]!"
	var/attack_message_attacker = "You [message_verb_simple] [src][message_hit_area] with [I]!"
	if(user in viewers(src))
		attack_message_spectator = "[user] [message_verb_continuous] [src][message_hit_area] with [I]!"
		attack_message_victim = "[user] [message_verb_continuous] you[message_hit_area] with [I]!"
	if(user == src)
		attack_message_victim = "You [message_verb_simple] yourself[message_hit_area] with [I]"
	visible_message("<span class='danger'>[attack_message_spectator]</span>",\
		"<span class='userdanger'>[attack_message_victim]</span>", null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='danger'>[attack_message_attacker]</span>")
	return 1

/mob/living/proc/send_item_poke_message(obj/item/I, mob/living/user)
	var/list/messages = list("poked", "prodded", "tapped", "nudged")
	var/message_verb = "[pick(messages)]"
	var/poke_message = "[src] is [message_verb] with [I]!"
	var/poke_message_local = "You're [message_verb] with [I]!"
	if(user in viewers(src))
		poke_message = "[user] [message_verb] [src] with [I]!"
		poke_message_local = "[user] [message_verb] you with [I]!"
	if(user == src)
		poke_message_local = "You [message_verb] yourself with [I]!"
	visible_message("<span class='notice'>[poke_message]</span>",\
	"<span class='usernotice'>[poke_message_local]</span>", null, COMBAT_MESSAGE_RANGE)

/mob/living/proc/record_accidental_poking()
	if(time_of_last_poke != 0 && world.time - time_of_last_poke <= 50)
		SSblackbox.record_feedback("tally", "poking_data", 1, "Hit someone shortly after poking them")

/mob/living/proc/check_for_accidental_attack()
	addtimer(CALLBACK(src, PROC_REF(record_accidental_attack), time_of_last_attack_dealt), 100, TIMER_OVERRIDE|TIMER_UNIQUE)

/mob/living/proc/record_accidental_attack(var/time)
	if(time_of_last_attack_dealt == 0) // We haven't attacked at all
		return
	if(time_of_last_attack_dealt > time) //We attacked again after the proc got called
		return
	//10 seconds passed after we last attacked someone - either it was an accident, or we robusted someone into being horizontal
	if(time_of_last_attack_dealt > time_of_last_attack_received + 100)
		SSblackbox.record_feedback("tally", "accidental_attack_data", 1, "Lasted ten seconds of not being hit after hitting somoene")
