/datum/movespeed_modifier/supply_pack
	multiplicative_slowdown = 0.35

/datum/storage/supply_pack
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 70
	max_slots = 20

/obj/item/storage/supply_pack
	name = "supply pack"
	desc = "A gargantuan storage pack fused to the carrier's torso."
	icon = 'icons/obj/storage/backpack.dmi'
	worn_icon = 'icons/mob/clothing/back/backpack.dmi'
	icon_state = "supply_pack"
	slot_flags = ITEM_SLOT_BACK
	storage_type = /datum/storage/supply_pack
	w_class = WEIGHT_CLASS_BULKY

/datum/status_effect/ipc_upgrade/supply_pack
	id = "ipc supply pack"
	name = "Supply Pack"
	slot = UPGRADE_UTILITY
	item_type = /obj/item/ipc_upgrade/supply_pack
	var/obj/item/storage/supply_pack/pack

/datum/status_effect/ipc_upgrade/supply_pack/on_apply()
	. = ..()
	pack = new
	pack.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(pack, TRAIT_NODROP, UPGRADE_TRAIT)

	if(!owner.dropItemToGround(owner.get_item_by_slot(ITEM_SLOT_BACK), TRUE))
		return FALSE
	owner.equip_to_slot_if_possible(pack, ITEM_SLOT_BACK)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/supply_pack)

/datum/status_effect/ipc_upgrade/supply_pack/on_remove()
	. = ..()
	pack.emptyStorage()
	QDEL_NULL(pack)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/supply_pack)
