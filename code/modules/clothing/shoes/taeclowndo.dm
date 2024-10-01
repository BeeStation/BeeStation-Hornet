/obj/item/clothing/shoes/clown_shoes/taeclowndo
	var/list/spelltypes = list	(
								/datum/action/cooldown/spell/conjure_item/summon_pie,
								/datum/action/cooldown/spell/pointed/banana_peel,
								/datum/action/cooldown/spell/touch/megahonk,
								/datum/action/cooldown/spell/touch/bspie,
								)
	var/list/spells = list()


/obj/item/clothing/shoes/clown_shoes/taeclowndo/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == ITEM_SLOT_FEET)
		spells = new
		for(var/spell in spelltypes)
			var/datum/action/cooldown/spell/S = new spell
			S.Grant(H)

/obj/item/clothing/shoes/clown_shoes/taeclowndo/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_FEET) == src)
		for(var/spell in spells)
			var/datum/action/cooldown/spell/S = spell
			S.Remove(H)
			qdel(S)
