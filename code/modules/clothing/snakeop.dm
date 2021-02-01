/obj/item/snake_op_transform
	name = "Snake Operative Device"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "radio"
	desc = "Pacifies you and grants you all the gear of a true stealth agent. Instant clotheswap not at all reverse-engineered from magical girl animes."
	var/used_up = FALSE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/snake_op_transform/attack_self(mob/user)
	if(used_up)
	else
		to_chat(user,"<span class='notice'>You activate the Snake Operative Device. You've been given fast-track access to elite Syndicate technology, good luck out there soldier.</span>")
		var/mob/living/carbon/human/H = user
		if(ishuman(user))
			ADD_TRAIT(user, TRAIT_PACIFISM, TRAIT_SNAKEOP)
			ADD_TRAIT(user, TRAIT_ALWAYS_CLEAN, TRAIT_SNAKEOP)

			user.dropItemToGround(H.w_uniform)
			user.dropItemToGround(H.wear_mask)
			user.dropItemToGround(H.glasses)
			user.dropItemToGround(H.gloves)
			user.dropItemToGround(H.shoes)
			user.dropItemToGround(H.belt)
			user.dropItemToGround(H.shoes)
			user.dropItemToGround(H.wear_id)
			user.dropItemToGround(H.back)
			user.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate/combat/snake(user), SLOT_W_UNIFORM)
			user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate/snake(user), SLOT_WEAR_MASK)
			user.equip_to_slot_or_del(new /obj/item/clothing/glasses/night(user), SLOT_GLASSES)
			user.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat/snake(user), SLOT_GLOVES)
			user.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/snake(user), SLOT_SHOES)
			user.equip_to_slot_or_del(new /obj/item/storage/belt/military/assault(user), SLOT_BELT)
			user.equip_to_slot_or_del(new /obj/item/card/id/syndicate(user), SLOT_WEAR_ID)
			user.equip_to_slot_or_del(new /obj/item/storage/backpack/duffelbag/syndie/snake(user), SLOT_BACK)
			user.equip_to_slot_or_del(new /obj/item/book/granter/martial/cqc(user), SLOT_IN_BACKPACK)
			user.equip_to_slot_or_del(new /obj/item/chameleon(user), SLOT_IN_BACKPACK)
			user.equip_to_slot_or_del(new /obj/item/storage/box/syndie_kit/space(user), SLOT_IN_BACKPACK)

			used_up = TRUE

/obj/item/clothing/under/syndicate/combat/snake
    resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/under/syndicate/combat/snake/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SNAKEOP)

/obj/item/clothing/mask/gas/syndicate/snake
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_cover = MASKCOVERSEYES //can eat through it
	visor_flags_cover = MASKCOVERSEYES //unnecessary?

/obj/item/clothing/mask/gas/syndicate/snake/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SNAKEOP)

/obj/item/clothing/gloves/combat/snake
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/gloves/combat/snake/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SNAKEOP)

/obj/item/clothing/shoes/combat/snake
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/shoes/combat/snake/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SNAKEOP)

/obj/item/storage/backpack/duffelbag/syndie/snake
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/storage/backpack/duffelbag/syndie/snake/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_SNAKEOP)
