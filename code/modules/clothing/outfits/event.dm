/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	suit = /obj/item/clothing/suit/space/santa
	head = /obj/item/clothing/head/costume/santa
	back = /obj/item/storage/backpack/santabag
	r_pocket = /obj/item/flashlight
	gloves = /obj/item/clothing/gloves/color/red

	box = /obj/item/storage/box/survival/engineer
	backpack_contents = list(/obj/item/a_gift/anything = 5)

/datum/outfit/santa/post_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(visuals_only)
		return
	H.fully_replace_character_name(H.real_name, "Santa Claus")
	if(H.mind)
		H.mind.assigned_role = "Santa"
		H.mind.special_role = "Santa"

	H.hair_style = "Long Hair 3"
	H.facial_hair_style = "Beard (Full)"
	H.hair_color = "FFF"
	H.facial_hair_color = "FFF"
	H.update_hair()
