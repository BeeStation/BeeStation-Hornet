/datum/mutation/cluwne
	name = "Cluwne"
	desc = "Turns a person into a Cluwne, a poor soul cursed to a short and miserable life by the honkmother."
	quality = NEGATIVE
	locked = TRUE
	mutadone_proof = TRUE
	var/list/datum/weakref/clothing_weakrefs = list()

/datum/mutation/cluwne/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.dna.add_mutation(/datum/mutation/clumsy)
	owner.dna.add_mutation(/datum/mutation/epilepsy)
	owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)

	playsound(owner.loc, 'sound/misc/bikehorn_creepy.ogg', vol = 50, vary = TRUE)
	owner.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(owner), ITEM_SLOT_BACK) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	equip_cursed_clothing(/obj/item/clothing/mask/cluwne, ITEM_SLOT_MASK)
	equip_cursed_clothing(/obj/item/clothing/under/cluwne, ITEM_SLOT_ICLOTHING)
	equip_cursed_clothing(/obj/item/clothing/shoes/cluwne, ITEM_SLOT_FEET)
	equip_cursed_clothing(/obj/item/clothing/gloves/color/white, ITEM_SLOT_GLOVES)
	owner.regenerate_icons()

/datum/mutation/cluwne/on_life()
	if(prob(15) && owner.IsUnconscious())
		owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)
		switch(rand(1, 6))
			if(1)
				owner.say("HONK", forced = "cluwne")
			if(2 to 5)
				owner.emote("scream")
			if(6)
				owner.Stun(1)
				owner.Knockdown(20)
				owner.set_jitter_if_lower(1000)

/datum/mutation/cluwne/on_losing(mob/living/carbon/owner)
	owner.emote("scream")
	owner.visible_message(span_warning("[span_name("[owner]")] faints as [owner.p_their()] cursed cluwne clothing melts away!"))
	owner.Unconscious(rand(45 SECONDS, 70 SECONDS))
	owner.dna.remove_mutation(/datum/mutation/clumsy)
	owner.dna.remove_mutation(/datum/mutation/epilepsy)
	for(var/datum/weakref/clothing_weakref in clothing_weakrefs)
		var/obj/item/clothing/clothing = clothing_weakref.resolve()
		if(QDELETED(clothing))
			continue
		if(!owner.doUnEquip(clothing, force = TRUE, silent = TRUE))
			qdel(clothing)
	clothing_weakrefs.Cut()

/datum/mutation/cluwne/proc/equip_cursed_clothing(type, slot)
	var/obj/item/clothing/original_clothing = owner.get_item_by_slot(slot)
	if(istype(original_clothing, type))
		return
	if(!QDELETED(original_clothing) && !owner.doUnEquip(original_clothing, silent = TRUE))
		qdel(original_clothing)
	var/obj/item/clothing/cursed_clothing = new type(owner)
	if(owner.equip_to_slot_or_del(cursed_clothing, slot))
		clothing_weakrefs += WEAKREF(cursed_clothing)

/mob/living/carbon/proc/cluwneify(cursed = FALSE)
	dna.add_mutation(cursed ? /datum/mutation/cluwne/cursed : /datum/mutation/cluwne)
	emote("scream")
	regenerate_icons()
	visible_message(span_danger("[span_name("[src]'s")] body glows green, the glow dissipating only to leave behind a cluwne formerly known as [span_name("[src]")]!"), \
					span_danger("Your brain feels like it's being torn apart, there is only the honkmother now."))
	flash_act(override_blindness_check = TRUE)
	client?.give_award(/datum/award/achievement/misc/cluwne, src)

/datum/mutation/cluwne/cursed
	scrambled = TRUE
