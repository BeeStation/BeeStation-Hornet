/obj/item/clothing/shoes/clown_shoes/taeclowndo
	actions_types = list(
		/datum/action/spell/conjure_item/summon_pie,
		/datum/action/spell/pointed/banana_peel,
		/datum/action/spell/touch/megahonk,
		/datum/action/spell/touch/bspie,
	)

/obj/item/clothing/shoes/clown_shoes/taeclowndo/item_action_slot_check(slot, mob/user)
	return slot == ITEM_SLOT_FEET