/obj/item/clothing/shoes/clown_shoes/taeclowndo
	actions_types = list(
		/datum/action/cooldown/spell/conjure_item/summon_pie,
		/datum/action/cooldown/spell/pointed/banana_peel,
		/datum/action/cooldown/spell/touch/megahonk,
		/datum/action/cooldown/spell/touch/bspie,
	)

//we only want to grant the powers to true clowns, not those fakers that remove their clumsiness
/obj/item/clothing/shoes/clown_shoes/taeclowndo/item_action_slot_check(slot, mob/user)
	return slot == ITEM_SLOT_FEET && (HAS_TRAIT(user, TRAIT_CLUMSY) || (user.mind && user.mind.assigned_role == JOB_NAME_CLOWN))
