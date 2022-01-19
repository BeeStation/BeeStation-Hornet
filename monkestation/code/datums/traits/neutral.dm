/datum/quirk/bald
	name = "Bald"
	desc = "Your hair seems to have gone missing. Luckily, you will spawn with a wig."
	value = 0

/datum/quirk/bald/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/head/wig/W = new
	W.hair_color = "#[H.hair_color]"
	W.hair_style = H.hair_style
	log_world(H.hair_color)
	log_world(H.hair_style)
	H.equip_to_slot_if_possible(W, ITEM_SLOT_BACKPACK)
	W.update_icon()
	H.dna.species.go_bald(H)
