/// This provides different types of magic resistance on an object
/datum/component/anti_magic
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/static/identifier_current = 0
	var/identifier
	var/source

	/// A bitflag with the types of magic resistance on the object
	var/antimagic_flags
	/// The amount of times the object can protect the user from magic
	var/charges
	/// The inventory slot the object must be located at in order to activate
	var/inventory_flags
	/// The proc that is triggered when an object has been drained a antimagic charge
	var/datum/callback/drain_antimagic
	/// The proc that is triggered when the object is depleted of charges
	var/datum/callback/expiration
	/// If we have already sent a notification message to the mob picking up an antimagic item
	var/casting_restriction_alert = FALSE


/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has the correct resistance
 * against the type of magic being used
 *
 * args:
 * * antimagic_flags (optional) A bitflag with the types of magic resistance on the object
 * * charges (optional) The amount of times the object can protect the user from magic
 * * inventory_flags (optional) The inventory slot the object must be located at in order to activate
 * * drain_antimagic (optional) The proc that is triggered when an object has been drained a antimagic charge
 * * expiration (optional) The proc that is triggered when the object is depleted of charges
 * *
 * antimagic bitflags: (see code/__DEFINES/magic.dm)
 * * MAGIC_RESISTANCE - Default magic resistance that blocks normal magic (wizard, spells, staffs)
 * * MAGIC_RESISTANCE_MIND - Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
 * * MAGIC_RESISTANCE_HOLY - Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god)
**/

/datum/component/anti_magic/Initialize(
	_source,
	antimagic_flags = MAGIC_RESISTANCE,
	charges = INFINITY,
	inventory_flags = ~ITEM_SLOT_BACKPACK, // items in a backpack won't activate, anywhere else is fine
	datum/callback/drain_antimagic,
	datum/callback/expiration
	)

	// Random enough that it will never conflict, and avoids having a static variable
	identifier = identifier_current++
	source = _source


	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(block_receiving_magic), override = TRUE)
		RegisterSignal(parent, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(restrict_casting_magic), override = TRUE)
		to_chat(parent, ("<span class='warning'>Magic seems to flee from you. You are immune to spells but are unable to cast magic.</span>"))
		var/mob/mob_parent = parent
		ADD_TRAIT(mob_parent, TRAIT_SEE_ANTIMAGIC, identifier)
		var/image/forbearance = image('icons/effects/genetics.dmi', mob_parent, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(mob_parent.layer, MUTATIONS_LAYER))
		forbearance.plane = mob_parent.plane
		mob_parent.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
		mob_parent.update_alt_appearances()
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/anti_magic/Destroy(force, silent)
	QDEL_NULL(drain_antimagic)
	QDEL_NULL(expiration)
	if(ismob(parent)) //If the component is attached to an item, it should go through on_drop instead.
		var/mob/user = parent
		UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
		REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
		user.remove_alt_appearance("magic_protection_[identifier]")
		user.update_alt_appearances()
	return ..()


/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		UnregisterSignal(equipper, COMSIG_MOB_RESTRICT_MAGIC)
		equipper.update_action_buttons()
		REMOVE_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC, identifier)
		equipper.remove_alt_appearance("magic_protection_[identifier]")
		equipper.update_alt_appearances()
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(block_receiving_magic), TRUE)
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(restrict_casting_magic), TRUE)
	equipper.update_action_buttons()
	// Gain a protection aura
	ADD_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC, identifier)
	var/image/forbearance = image('icons/effects/genetics.dmi', equipper, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(equipper.layer, MUTATIONS_LAYER))
	forbearance.plane = equipper.plane
	equipper.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
	equipper.update_alt_appearances()

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
	UnregisterSignal(user, COMSIG_MOB_RESTRICT_MAGIC)
	user.update_action_buttons()
	REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
	user.remove_alt_appearance("magic_protection_[identifier]")
	user.update_alt_appearances()


/datum/component/anti_magic/proc/block_receiving_magic(mob/living/carbon/user, casted_magic_flags, charge_cost, list/protection_was_used)
	SIGNAL_HANDLER

	// if any protection sources exist in our list then we already blocked the magic
	if(!istype(user) || protection_was_used.len)
		return

	// disclaimer - All anti_magic sources will be drained a charge_cost
	if(casted_magic_flags & antimagic_flags)
		var/mutable_appearance/antimagic_effect
		var/antimagic_color
		// im a programmer not shakesphere to the future grammar nazis that come after me for this
		var/visible_subject = ismob(parent) ? "[user.p_they()]" : "[parent]"
		var/self_subject = ismob(parent) ? "you" : "[parent]"

		if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE)
			user.visible_message(
				("<span class='warning'>[user] pulses red as [visible_subject] absorbs magic energy!</span>"),
				("<span class='userdanger'>An intense magical aura pulses around [self_subject] as it dissipates into the air!</span>"),
			)
			antimagic_effect = mutable_appearance('icons/effects/effects.dmi', "shield-red", MOB_SHIELD_LAYER)
			antimagic_color = LIGHT_COLOR_BLOOD_MAGIC
			playsound(user, 'sound/magic/magic_block.ogg', 50, TRUE)
		else if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE_HOLY)
			user.visible_message(
				("<span class='warning'>[user] starts to glow as [visible_subject] emits a halo of light!</span>"),
				("<span class='userdanger'>A feeling of warmth washes over [self_subject] as rays of light surround your body and protect you!</span>"),
			)
			antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
			antimagic_color = LIGHT_COLOR_HOLY_MAGIC
			playsound(user, 'sound/magic/magic_block_holy.ogg', 50, TRUE)
		else if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE_MIND)
			user.visible_message(
				("<span class='warning'>[user] forehead shines as [visible_subject] repulses magic from their mind!</span>"),
				("<span class='userdanger'>A feeling of cold splashes on [self_subject] as your forehead reflects magic usering your mind!</span>"),
			)
			antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "telekinesishead", MOB_SHIELD_LAYER)
			antimagic_color = LIGHT_COLOR_DARK_BLUE
			playsound(user, 'sound/magic/magic_block_mind.ogg', 50, TRUE)

		user.mob_light(range = 2, color = antimagic_color, duration = 5 SECONDS)
		user.add_overlay(antimagic_effect)
		addtimer(CALLBACK(user, /atom/proc/cut_overlay, antimagic_effect), 50)

		if(ismob(parent))
			return COMPONENT_MAGIC_BLOCKED

		var/has_limited_charges = !(charges == INFINITY)
		var/charge_was_drained = charge_cost > 0
		if(has_limited_charges && charge_was_drained)
			protection_was_used += parent
			drain_antimagic?.Invoke(user, parent)
			charges -= charge_cost
			if(charges <= 0)
				expiration?.Invoke(user, parent)
				qdel(src)
		return COMPONENT_MAGIC_BLOCKED
	return NONE

/// cannot cast magic with the same type of antimagic present
/datum/component/anti_magic/proc/restrict_casting_magic(mob/user, magic_flags)
	SIGNAL_HANDLER

	if(magic_flags & antimagic_flags)
		return COMPONENT_MAGIC_BLOCKED
	return NONE
