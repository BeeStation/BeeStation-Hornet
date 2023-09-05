
/**
 * Attempt to use an item on a specific target.
 */
/obj/item/proc/use_on(mob/user, atom/target, params)
	SHOULD_NOT_OVERRIDE(TRUE)
	// Harm intent always disables safe interactions and goes straight to attacking
	if (user.a_intent != INTENT_HARM && tool_action(user, target))
		return
	if (QDELETED(src))
		return
	// Perform pre attack actions
	if(!pre_attack(target, user, params))
		return
	// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
	var/resolved = attack(user, target, params) || target.attackby(src, user, params)
	if(!resolved && target && !QDELETED(src))
		afterattack(target, user, 1, params)

/**
 * Deals an attack to the target, by default using this
 * item's damage source profile.
 *
 * You may override this if you want to completely replace an object's
 * attack function with another one that does something else. For example,
 * play a sound instead of deal damage.
 *
 * If you want something to happen as a result of an attack use afterattack or
 * pre_attack instead. Overriding this proc is strictly for replacing the
 * damage dealing property of an item with some other property.
 *
 * If introducing swing combat, then that should be introduced at either the
 * damage_source level or deal_attack level.
 */
/obj/item/proc/attack(mob/living/user, atom/target, params)
	//if(item_flags & NOBLUDGEON)
	//	return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(target)
	// By default deal our generic attack
	deal_attack(user, target, user.zone_selected)

/**
 * Called to perform actions specific to certain tools.
 * By default will pass on the tool behaviour to be used by the target instead of
 * performing an action here, but you can add specific tool behaviours in here if you want.
 */
/obj/item/proc/tool_action(mob/user, atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (interact_with(src, target) || QDELETED(src))
		return TRUE
	if (target.item_interact(src, user) || QDELETED(src))
		return TRUE
	if(!tool_behaviour)
		return FALSE
	return target.tool_act(user, src, tool_behaviour)

/**
 * The majority of attackby was converted to this.
 * Called when someone attempts to use an item on this device.
 * Returns true if the interaction happened meaning that the user will not proceed to hit
 * the object.
 * You should **always** return true if the item has any interaction at all, even if that interaction
 * did not go through.
 * If the user is on harm intent, this will never be called in the first place. If you want a response
 * on harm intent, then it needs to respond to being attacked rather than trying to use an item
 * peacefully on it.
 */
/atom/proc/item_interact(obj/item/item, mob/user, params)
	return FALSE

/**
 * Check if this item can interact with another item.
 * Returns false if no interact occurred, returns true if an interact
 * happened in which case attack will not continue.
 */
/obj/item/proc/interact_with(atom/target, mob/user, params)
	if ((SEND_SIGNAL(src, COMSIG_ITEM_INTERACT_WITH, target, user, params)) & COMPONENT_INTERACTION_SUCCESS)
		return TRUE
	return FALSE

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	interact(user)

/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_NO_ATTACK)
		return FALSE
	return TRUE //return FALSE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/mob/living/attackby(obj/item/I, mob/living/user, params)
	if(..())
		return TRUE
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.a_intent == INTENT_HARM && stat == DEAD && (butcher_results || guaranteed_butcher_results)) //can we butcher it?
		var/datum/component/butchering/butchering = I.GetComponent(/datum/component/butchering)
		if(butchering?.butchering_enabled)
			to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
			playsound(loc, butchering.butcher_sound, 50, TRUE, -1)
			if(do_after(user, butchering.speed, src) && Adjacent(I))
				butchering.Butcher(user, src)
			return 1
		else if(I.is_sharp() && !butchering) //give sharp objects butchering functionality, for consistency
			I.AddComponent(/datum/component/butchering, 80 * I.toolspeed)
			attackby(I, user, params) //call the attackby again to refresh and do the butchering check again
			return
	return I.attack_mob_target(src, user)


/obj/item/proc/attack_mob_target(mob/living/M, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	SEND_SIGNAL(M, COMSIG_MOB_ITEM_ATTACKBY, user, src)

	var/nonharmfulhit = FALSE

	if(user.a_intent == INTENT_HELP && !(item_flags & ISWEAPON))
		nonharmfulhit = TRUE
	for(var/datum/surgery/S in M.surgeries)
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
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	user.do_attack_animation(M)
	var/time = world.time
	if(nonharmfulhit)
		M.send_item_poke_message(src, user)
		user.time_of_last_poke = time
	else
		user.record_accidental_poking()
		M.on_attacked(src, user)
		M.time_of_last_attack_recieved = time
		user.time_of_last_attack_dealt = time
		user.check_for_accidental_attack()

	log_combat(user, M, "[nonharmfulhit ? "poked" : "attacked"]", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

/atom/proc/on_attacked()
	return

/obj/on_attacked(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message("<span class='danger'>[user] hits [src] with [I]!</span>", \
					"<span class='danger'>You hit [src] with [I]!</span>", null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		log_combat(user, src, "attacked", I)
	take_damage(I.force, I.damtype, MELEE, 1)

/mob/living/on_attacked(obj/item/I, mob/living/user)
	return I.deal_attack(user, src, ran_zone(user.zone_selected))

/mob/living/simple_animal/on_attacked(obj/item/I, mob/living/user, nonharmfulhit = FALSE)
	if(I.force < force_threshold || I.damtype == STAMINA_DAMTYPE || nonharmfulhit)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), 1, -1)
	else
		return ..()

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, src, proximity_flag, click_parameters)


/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return CLAMP((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return CLAMP(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area)
	var/message_verb = "attacked"
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "[src] is [message_verb][message_hit_area] with [I]!"
	var/attack_message_local = "You're [message_verb][message_hit_area] with [I]!"
	if(user in viewers(src))
		attack_message = "[user] [message_verb] [src][message_hit_area] with [I]!"
		attack_message_local = "[user] [message_verb] you[message_hit_area] with [I]!"
	if(user == src)
		attack_message_local = "You [message_verb] yourself[message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message]</span>",\
	"<span class='userdanger'>[attack_message_local]</span>", null, COMBAT_MESSAGE_RANGE)
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
	if(time_of_last_attack_dealt > time_of_last_attack_recieved + 100)
		SSblackbox.record_feedback("tally", "accidental_attack_data", 1, "Lasted ten seconds of not being hit after hitting somoene")
