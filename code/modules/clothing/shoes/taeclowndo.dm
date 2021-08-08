/obj/item/clothing/shoes/clown_shoes/taeclowndo
	var/list/spelltypes = list	(
								/obj/effect/proc_holder/spell/targeted/conjure_item/summon_pie,
								/obj/effect/proc_holder/spell/aimed/banana_peel,
								/obj/effect/proc_holder/spell/targeted/touch/megahonk,
								/obj/effect/proc_holder/spell/targeted/touch/bspie,
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
			var/obj/effect/proc_holder/spell/S = new spell
			spells += S
			S.charge_counter = 0
			S.start_recharge()
			H.mind.AddSpell(S)

/obj/item/clothing/shoes/clown_shoes/taeclowndo/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_FEET) == src)
		for(var/spell in spells)
			var/obj/effect/proc_holder/spell/S = spell
			H.mind.spell_list.Remove(S)
			qdel(S)