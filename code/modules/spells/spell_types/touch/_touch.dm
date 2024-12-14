/datum/action/spell/touch
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = 'sound/items/welder.ogg'
	invocation = "High Five!"
	invocation_type = INVOCATION_SHOUT

	/// Typepath of what hand we create on initial cast.
	var/obj/item/melee/touch_attack/hand_path = /obj/item/melee/touch_attack
	/// Ref to the hand we currently have deployed.
	var/obj/item/melee/touch_attack/attached_hand
	/// The message displayed to the person upon creating the touch hand
	var/draw_message = ("<span class='notice'>You channel the power of the spell to your hand.</span>")
	/// The message displayed upon willingly dropping / deleting / cancelling the touch hand before using it
	var/drop_message = ("<span class='notice'>You draw the power out of your hand.</span>")

/datum/action/spell/touch/Destroy()
	// If we have an owner, the hand is cleaned up in Remove(), which Destroy() calls.
	if(!owner)
		QDEL_NULL(attached_hand)
	return ..()

/datum/action/spell/touch/Remove(mob/living/remove_from)
	remove_hand(remove_from)
	return ..()

/datum/action/spell/touch/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	. = ..()
	if(!button)
		return
	if(attached_hand)
		button.color = COLOR_GREEN

/datum/action/spell/touch/update_stat_status(list/stat)
	if(attached_hand)
		stat[STAT_STATUS] = GENERATE_STAT_TEXT("[capitalize(name)] is currently active!")

/datum/action/spell/touch/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(!(carbon_owner.mobility_flags & MOBILITY_USE))
		return FALSE
	return TRUE

/datum/action/spell/touch/is_valid_spell(mob/user, atom/target)
	return iscarbon(user)

/**
 * Creates a new hand_path hand and equips it to the caster.
 *
 * If the equipping action fails, reverts the cooldown and returns FALSE.
 * Otherwise, registers signals and returns TRUE.
 */
/datum/action/spell/touch/proc/create_hand(mob/living/carbon/cast_on)
	var/obj/item/melee/touch_attack/new_hand = new hand_path(cast_on, src)
	if(!cast_on.put_in_hands(new_hand, del_on_fail = TRUE))
		reset_spell_cooldown()
		if (cast_on.usable_hands == 0)
			to_chat(cast_on, ("<span class='warning'>You dont have any usable hands!</span>"))
		else
			to_chat(cast_on, ("<span class='warning'>Your hands are full!</span>"))
		return FALSE

	attached_hand = new_hand
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_hand_hit))
	RegisterSignal(attached_hand, COMSIG_PARENT_QDELETING, PROC_REF(on_hand_deleted))
	RegisterSignal(attached_hand, COMSIG_ITEM_DROPPED, PROC_REF(on_hand_dropped))
	to_chat(cast_on, draw_message)
	return TRUE

/**
 * Unregisters any signals and deletes the hand currently summoned by the spell.
 *
 * If reset_cooldown_after is TRUE, we will additionally refund the cooldown of the spell.
 * If reset_cooldown_after is FALSE, we will instead just start the spell's cooldown
 */
/datum/action/spell/touch/proc/remove_hand(mob/living/hand_owner, reset_cooldown_after = FALSE)
	if(!QDELETED(attached_hand))
		UnregisterSignal(attached_hand, list(COMSIG_ITEM_AFTERATTACK, COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED))
		hand_owner?.temporarilyRemoveItemFromInventory(attached_hand)
		QDEL_NULL(attached_hand)

	if(reset_cooldown_after)
		if(hand_owner)
			to_chat(hand_owner, drop_message)
		reset_spell_cooldown()
	else
		start_cooldown()

// Touch spells don't go on cooldown OR give off an invocation until the hand is used itself.
/datum/action/spell/touch/pre_cast(mob/user, atom/target)
	return ..() | SPELL_NO_FEEDBACK | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/spell/touch/on_cast(mob/living/carbon/user, atom/target)
	. = ..()
	if(!QDELETED(attached_hand) && (attached_hand in user.held_items))
		remove_hand(user, reset_cooldown_after = TRUE)
		return

	create_hand(user)
	return ..()

/**
 * Signal proc for [COMSIG_ITEM_AFTERATTACK] from our attached hand.
 *
 * When our hand hits an atom, we can cast do_hand_hit() on them.
 */
/datum/action/spell/touch/proc/on_hand_hit(datum/source, atom/victim, mob/caster, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	if(victim == caster)
		return
	if(!can_cast_spell(feedback = FALSE))
		return

	INVOKE_ASYNC(src, PROC_REF(do_hand_hit), source, victim, caster)


/**
 * Calls cast_on_hand_hit() from the caster onto the victim.
 */
/datum/action/spell/touch/proc/do_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	SEND_SIGNAL(src, COMSIG_SPELL_TOUCH_HAND_HIT, victim, caster, hand)
	if(!cast_on_hand_hit(hand, victim, caster))
		return

	log_combat(caster, victim, "cast the touch spell [name] on", hand)
	spell_feedback()
	remove_hand(caster)


/**
 * The actual process of casting the spell on the victim from the caster.
 *
 * Override / extend this to implement casting effects.
 * Return TRUE on a successful cast to use up the hand (delete it)
 * Return FALSE to do nothing and let them keep the hand in hand
 */
/datum/action/spell/touch/proc/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	return FALSE



/**
 * Signal proc for [COMSIG_PARENT_QDELETING] from our attached hand.
 *
 * If our hand is deleted for a reason unrelated to our spell,
 * unlink it (clear refs) and revert the cooldown
 */
/datum/action/spell/touch/proc/on_hand_deleted(datum/source)
	SIGNAL_HANDLER

	remove_hand(reset_cooldown_after = TRUE)

/**
 * Signal proc for [COMSIG_ITEM_DROPPED] from our attached hand.
 *
 * If our caster drops the hand, remove the hand / revert the cast
 * Basically gives them an easy hotkey to lose their hand without needing to click the button
 */
/datum/action/spell/touch/proc/on_hand_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER

	remove_hand(dropper, reset_cooldown_after = TRUE)

/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "latexballon"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	/// A weakref to what spell made us.
	var/datum/weakref/spell_which_made_us

/obj/item/melee/touch_attack/Initialize(mapload, datum/action/spell/spell)
	. = ..()

	if(spell)
		spell_which_made_us = WEAKREF(spell)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return TRUE
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, ("<span class='warning'>You can't reach out!</span>"))
		return TRUE
	return ..()

/**
 * When the hand component of a touch spell is qdel'd, (the hand is dropped or otherwise lost),
 * the cooldown on the spell that made it is automatically refunded.
 *
 * However, if you want to consume the hand and not give a cooldown,
 * such as adding a unique behavior to the hand specifically, this function will do that.
 */
/obj/item/melee/touch_attack/proc/remove_hand_with_no_refund(mob/holder)
	var/datum/action/spell/touch/hand_spell = spell_which_made_us?.resolve()
	if(!QDELETED(hand_spell))
		hand_spell.remove_hand(holder, reset_cooldown_after = FALSE)
		return

	// We have no spell associated for some reason, just delete us as normal.
	holder.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)
