/datum/component/anti_magic
	var/magic = FALSE
	var/holy = FALSE
	var/charges = INFINITY
	var/blocks_self = TRUE
	var/allowed_slots = ~ITEM_SLOT_BACKPACK
	var/datum/callback/reaction
	var/datum/callback/expire

/datum/component/anti_magic/Initialize(_magic = FALSE, _holy = FALSE, _charges, _blocks_self = TRUE, datum/callback/_reaction, datum/callback/_expire, _allowed_slots)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(protect))
	else
		return COMPONENT_INCOMPATIBLE

	magic = _magic
	holy = _holy
	if(!isnull(_charges))
		charges = _charges
	blocks_self = _blocks_self
	reaction = _reaction
	expire = _expire
	if(!isnull(_allowed_slots))
		allowed_slots = _allowed_slots

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(allowed_slots & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(protect), TRUE)

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)

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

