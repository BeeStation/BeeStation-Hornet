/datum/mutation/cluwne
	name = "Cluwne"
	desc = "Turns a person into a Cluwne, a poor soul cursed to a short and miserable life by the honkmother."
	quality = NEGATIVE
	locked = TRUE

/datum/mutation/cluwne/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.dna.add_mutation(CLOWNMUT)
	owner.dna.add_mutation(EPILEPSY)
	owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)

	playsound(owner.loc, 'sound/misc/bikehorn_creepy.ogg', 50, 1)
	owner.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(owner), ITEM_SLOT_BACK) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	if(!istype(owner.wear_mask, /obj/item/clothing/mask/cluwne))
		if(!owner.doUnEquip(owner.wear_mask))
			qdel(owner.wear_mask)
		owner.equip_to_slot_or_del(new /obj/item/clothing/mask/cluwne(owner), ITEM_SLOT_MASK)

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(!istype(H.w_uniform, /obj/item/clothing/under/cluwne))
			if(!H.doUnEquip(H.w_uniform))
				qdel(H.w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/cluwne(H), ITEM_SLOT_ICLOTHING)
		if(!istype(H.shoes, /obj/item/clothing/shoes/cluwne))
			if(!H.doUnEquip(H.shoes))
				qdel(H.shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/cluwne(H), ITEM_SLOT_FEET)
		owner.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(owner), ITEM_SLOT_GLOVES) // ditto

/datum/mutation/cluwne/on_life()
	if(prob(15) && owner.IsUnconscious())
		owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)
		switch(rand(1, 6))
			if(1)
				owner.say("HONK")
			if(2 to 5)
				owner.emote("scream")
			if(6)
				owner.Stun(1)
				owner.Knockdown(20)
				owner.Jitter(500)

/datum/mutation/cluwne/on_losing(mob/living/carbon/owner)
	owner.adjust_fire_stacks(1)
	owner.IgniteMob()
	owner.dna.add_mutation(CLUWNEMUT)

/mob/living/carbon/proc/cluwneify()
	dna.add_mutation(CLUWNEMUT)
	emote("scream")
	regenerate_icons()
	visible_message("<span class='danger'>[src]'s body glows green, the glow dissipating only to leave behind a cluwne formerly known as [src]!</span>", \
					"<span class='danger'>Your brain feels like it's being torn apart, there is only the honkmother now.</span>")
	flash_act()

	if (client)
		client.give_award(/datum/award/achievement/misc/cluwne, src)
