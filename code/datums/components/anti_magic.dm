/datum/component/anti_magic
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/source
	var/magic = FALSE
	var/holy = FALSE
	var/charges = INFINITY
	var/blocks_self = TRUE
	var/allowed_slots = ~ITEM_SLOT_BACKPACK
	var/datum/callback/reaction
	var/datum/callback/expire
	var/static/identifier_current = 0
	var/identifier

/datum/component/anti_magic/Initialize(_source, _magic = FALSE, _holy = FALSE, _charges, _blocks_self = TRUE, datum/callback/_reaction, datum/callback/_expire, _allowed_slots)
	// Random enough that it will never conflict, and avoids having a static variable
	identifier = identifier_current++
	source = _source
	magic = _magic
	holy = _holy
	if(!isnull(_charges))
		charges = _charges
	blocks_self = _blocks_self
	reaction = _reaction
	expire = _expire
	if(!isnull(_allowed_slots))
		allowed_slots = _allowed_slots

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(protect))
		var/mob/mob_parent = parent
		ADD_TRAIT(mob_parent, TRAIT_SEE_ANTIMAGIC, identifier)
		var/image/forbearance = image('icons/effects/genetics.dmi', mob_parent, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(mob_parent.layer, MUTATIONS_LAYER))
		forbearance.plane = mob_parent.plane
		mob_parent.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
		mob_parent.update_alt_appearances()
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(allowed_slots & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		REMOVE_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC, identifier)
		equipper.remove_alt_appearance("magic_protection_[identifier]")
		equipper.update_alt_appearances()
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(protect), TRUE)
	// Gain a protection aura
	ADD_TRAIT(equipper, TRAIT_SEE_ANTIMAGIC, identifier)
	var/image/forbearance = image('icons/effects/genetics.dmi', equipper, "servitude", MOB_OVERLAY_LAYER_ABSOLUTE(equipper.layer, MUTATIONS_LAYER))
	forbearance.plane = equipper.plane
	equipper.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/blessedAware, "magic_protection_[identifier]", forbearance)
	equipper.update_alt_appearances()

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
	REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
	user.remove_alt_appearance("magic_protection_[identifier]")
	user.update_alt_appearances()

/datum/component/anti_magic/Destroy(force, silent)
	if(ismob(parent)) //If the component is attached to an item, it should go through on_drop instead.
		var/mob/user = parent
		UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
		REMOVE_TRAIT(user, TRAIT_SEE_ANTIMAGIC, identifier)
		user.remove_alt_appearance("magic_protection_[identifier]")
		user.update_alt_appearances()
	return ..()

/datum/component/anti_magic/proc/protect(datum/source, mob/user, _magic, _holy, major, self, list/protection_sources)
	SIGNAL_HANDLER

	if(((_magic && magic) || (_holy && holy)) && (!self || blocks_self))
		protection_sources += parent
		reaction?.Invoke(user, major)
		if(major)
			charges--
			if(charges <= 0)
				expire?.Invoke(user)
		return COMPONENT_BLOCK_MAGIC
