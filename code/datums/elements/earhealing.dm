/datum/element/earhealing
	element_flags = ELEMENT_DETACH
	var/list/user_by_item = list()

/datum/element/earhealing/New()
	START_PROCESSING(SSdcs, src)

/datum/element/earhealing/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignals(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(equippedChanged))

/datum/element/earhealing/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	user_by_item -= target

/datum/element/earhealing/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_EARS && istype(user))
		user_by_item[source] = user
	else
		user_by_item -= source

/datum/element/earhealing/process(delta_time)
	for(var/i in user_by_item)
		var/mob/living/carbon/user = user_by_item[i]
		if(HAS_TRAIT(user, TRAIT_DEAF))
			continue
		var/obj/item/organ/ears/ears = user.get_organ_slot(ORGAN_SLOT_EARS)
		if(!ears)
			continue
		ears.deaf = max(ears.deaf - 0.25 * delta_time, (ears.damage < ears.maxHealth ? 0 : 1)) // Do not clear deafness if our ears are too damaged
		ears.damage = max(ears.damage - 0.025 * delta_time, 0)
		CHECK_TICK	// Reviewer: yes I really am afraid of 1000 clones with earmuffs
