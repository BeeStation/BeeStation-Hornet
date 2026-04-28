/datum/component/enchantment
	/// Examine text
	var/examine_description
	/// Maximum enchantment level
	var/max_level = 1
	/// Current enchantment level
	var/level

/datum/component/enchantment/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item = parent

	// Get random level
	level = rand(1, max_level)
	// Apply effect
	apply_effect(item)
	// Add in examine effect
	RegisterSignal(item, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/enchantment/Destroy()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	return ..()

/datum/component/enchantment/proc/apply_effect(obj/item/target)
	return

/datum/component/enchantment/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!examine_description)
		return

	if(IS_SERVANT_OF_RATVAR(user) || isobserver(user))
		examine_list += span_brass(examine_description)
		examine_list += span_neovgre("It's blessing has a power of [level]!")
	else
		examine_list += "It is glowing slightly!"
		var/mob/living/L = user
		if(istype(L.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/science))
			examine_list += "It emits a readable EMF factor of [level]."
