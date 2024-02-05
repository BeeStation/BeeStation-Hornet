///Component specifically for explosion sensetive things, currently only applies to heat based explosions but can later perhaps be used for things that are dangerous to handle carelessly like nitroglycerin.
/datum/component/explodable
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 2
	var/flash_range = 3
	/// Whether this explosion ignores the bombcap.
	var/uncapped
	/// Whether we always delete. Useful for nukes turned plasma and such, so they don't default delete and can survive
	var/delete_after
	/// For items, lets us determine where things should be hit.
	var/equipped_slot
	/// Whether this component is currently in the process of exploding.
	var/tmp/exploding = FALSE

/datum/component/explodable/Initialize(devastation_range, heavy_impact_range, light_impact_range, flash_range, uncapped = FALSE, delete_after = EXPLODABLE_DELETE_PARENT)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(explodable_attack))
	RegisterSignal(parent, COMSIG_TRY_STORAGE_INSERT, PROC_REF(explodable_insert_item))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(detonate))
	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(explodable_impact))
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(explodable_bump))
		if(isitem(parent))
			RegisterSignals(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT), PROC_REF(explodable_attack))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

	if (devastation_range)
		src.devastation_range = devastation_range
	if (heavy_impact_range)
		src.heavy_impact_range = heavy_impact_range
	if (light_impact_range)
		src.light_impact_range = light_impact_range
	if (flash_range)
		src.flash_range = flash_range
	src.uncapped = uncapped
	src.delete_after = delete_after

/datum/component/explodable/proc/explodable_insert_item(datum/source, obj/item/I, mob/M, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER

	check_if_detonate(I)

/datum/component/explodable/proc/explodable_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	check_if_detonate(hit_atom)

/datum/component/explodable/proc/explodable_bump(datum/source, atom/A)
	SIGNAL_HANDLER

	check_if_detonate(A)

///Called when you use this object to attack sopmething
/datum/component/explodable/proc/explodable_attack(datum/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER

	check_if_detonate(target)

///Called when you attack a specific body part of the thing this is equipped on. Useful for exploding pants.
/datum/component/explodable/proc/explodable_attack_zone(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER

	if(!def_zone)
		return
	if(damagetype != BURN) //Don't bother if it's not fire.
		return
	if(!is_hitting_zone(def_zone)) //You didn't hit us! ha!
		return
	detonate()

/datum/component/explodable/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	RegisterSignal(equipper, COMSIG_MOB_APPLY_DAMGE,  PROC_REF(explodable_attack_zone), TRUE)

/datum/component/explodable/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_APPLY_DAMGE)

/// Checks if we're hitting the zone this component is covering
/datum/component/explodable/proc/is_hitting_zone(def_zone)
	var/obj/item/item = parent
	var/mob/living/L = item.loc //Get whoever is equipping the item currently

	if(!istype(L))
		return

	var/obj/item/bodypart/bodypart = L.get_bodypart(check_zone(def_zone))

	var/list/equipment_items = list()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		equipment_items += list(C.head, C.wear_mask, C.back, C.gloves, C.shoes, C.glasses, C.ears)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			equipment_items += list(H.wear_suit, H.w_uniform, H.belt, H.s_store, H.wear_id)
		if(ismonkey(C))
			var/mob/living/carbon/monkey/H = C
			equipment_items += list(H.w_uniform)

	for(var/bp in equipment_items)
		if(!bp)
			continue

		var/obj/item/I = bp
		if(I.body_parts_covered & bodypart.body_part)
			return TRUE
	return FALSE


/datum/component/explodable/proc/check_if_detonate(target)
	if(!isitem(target))
		return
	var/obj/item/I = target
	if(!I.is_hot())
		return
	detonate() //If we're touching a hot item we go boom


/// Expldoe and remove the object
/datum/component/explodable/proc/detonate()
	SIGNAL_HANDLER
	if (exploding)
		return // If we don't do this and this doesn't delete it can lock the MC into only processing Input, Timers, and Explosions.

	var/atom/bomb = parent

	exploding = TRUE
	explosion(bomb, devastation_range, heavy_impact_range, light_impact_range, flash_range, uncapped) //epic explosion time

	switch(delete_after)
		if(EXPLODABLE_DELETE_SELF)
			qdel(src)
		if(EXPLODABLE_DELETE_PARENT)
			qdel(bomb)
		else
			addtimer(CALLBACK(src, PROC_REF(reset_exploding), 0.1 SECONDS))

/**
 * Resets the expoding flag
 */
/datum/component/explodable/proc/reset_exploding()
	SIGNAL_HANDLER
	src.exploding = FALSE


