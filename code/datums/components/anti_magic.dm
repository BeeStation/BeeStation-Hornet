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
	/// Whether we should, on equipping, alert the caster that this item can block any of their spells
	/// This changes between true and false on equip and drop, don't set it outright to something
	var/alert_caster_on_equip = TRUE


/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has the correct resistance
 * against the type of magic being used
 *
 * args:
 * * _source
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
	src.antimagic_flags = antimagic_flags
	src.charges = charges
	src.inventory_flags = inventory_flags
	src.drain_antimagic = drain_antimagic
	src.expiration = expiration

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else if(ismob(parent))
		register_antimagic_signals(parent)
		var/mob/mob_parent = parent
		ADD_TRAIT(mob_parent, TRAIT_SEE_ANTIMAGIC, identifier)
		var/image/forbearance = image('icons/effects/genetics.dmi', mob_parent, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(mob_parent.layer, MUTATIONS_LAYER))
		forbearance.plane = mob_parent.plane
		mob_parent.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
		mob_parent.update_alt_appearances()

	else
		return COMPONENT_INCOMPATIBLE

/datum/component/anti_magic/proc/register_antimagic_signals(datum/on_what)
	RegisterSignal(on_what, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(block_receiving_magic), override = TRUE)
	RegisterSignal(on_what, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(restrict_casting_magic), override = TRUE)

/datum/component/anti_magic/proc/unregister_antimagic_signals(datum/on_what)
	UnregisterSignal(on_what, list(COMSIG_MOB_RECEIVE_MAGIC, COMSIG_MOB_RESTRICT_MAGIC))

/datum/component/anti_magic/Destroy(force, silent)
	drain_antimagic = 0
	expiration = 0
	if(ismob(parent)) //If the component is attached to an item, it should go through on_drop instead.
		var/mob/user = parent
		UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
		REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
		user.remove_alt_appearance("magic_protection_[identifier]")
		user.update_alt_appearances()
	return ..()


/datum/component/anti_magic/proc/on_equip(atom/movable/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		unregister_antimagic_signals(equipper)
		equipper.update_action_buttons()
		REMOVE_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC, identifier)
		equipper.remove_alt_appearance("magic_protection_[identifier]")
		equipper.update_alt_appearances()
		return

	register_antimagic_signals(equipper)
	equipper.update_action_buttons()
	var/mob/mob_parent = equipper
	if(!HAS_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC))
		ADD_TRAIT(mob_parent, TRAIT_SEE_ANTIMAGIC, identifier)
		var/image/forbearance = image('icons/effects/genetics.dmi', mob_parent, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(mob_parent.layer, MUTATIONS_LAYER))
		forbearance.plane = mob_parent.plane
		mob_parent.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
		mob_parent.update_alt_appearances()

	if(!alert_caster_on_equip)
		return
// Check to see if we have any spells that are blocked due to antimagic
	for(var/datum/action/spell/magic_spell in equipper.actions)
		if(!(magic_spell.spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC))
			continue

		if(!(antimagic_flags & magic_spell.antimagic_flags))
			continue

		to_chat(equipper, ("<span class='warning'>[parent] is interfering with your ability to cast magic!</span>"))
		alert_caster_on_equip = FALSE
		break

/datum/component/anti_magic/proc/on_drop(atom/movable/source, mob/user)
	SIGNAL_HANDLER

	// Reset alert
	if(source.loc != user)
		alert_caster_on_equip = TRUE
	unregister_antimagic_signals(user)
	user.update_action_buttons()
	REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
	user.remove_alt_appearance("magic_protection_[identifier]")
	user.update_alt_appearances()

/datum/component/anti_magic/proc/block_receiving_magic(mob/living/carbon/source, casted_magic_flags, charge_cost, list/protection_was_used, list/antimagic_sources)
	SIGNAL_HANDLER

	// We do not block this type of magic, good day
	if(!(casted_magic_flags & antimagic_flags))
		return NONE

	// We have already blocked this spell
	if(parent in antimagic_sources)
		return NONE

	// Block success! Add this parent to the list of antimagic sources
	antimagic_sources += parent

	if((charges != INFINITY) && charge_cost > 0 && drain_antimagic)
		drain_antimagic?.Invoke(source, parent)
		charges -= charge_cost
		if(charges <= 0)
			expiration?.Invoke(source, parent)
			qdel(src) // no more antimagic

	return COMPONENT_MAGIC_BLOCKED

/// cannot cast magic with the same type of antimagic present
/datum/component/anti_magic/proc/restrict_casting_magic(mob/user, magic_flags)
	SIGNAL_HANDLER

	if(magic_flags & antimagic_flags)
		if(HAS_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK)) // this trait bypasses magic casting restrictions
			return NONE
		return COMPONENT_MAGIC_BLOCKED
	return NONE
