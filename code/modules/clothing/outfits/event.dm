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

/datum/outfit/santa/post_equip(mob/living/carbon/human/user, visualsOnly = FALSE)
	if(visualsOnly)
		return
	user.fully_replace_character_name(user.real_name, "Santa Claus")
	user.mind.set_assigned_role(SSjob.GetJobType(/datum/job/santa))
	user.mind.special_role = ROLE_SANTA

	user.hair_style = "Long Hair 3"
	user.facial_hair_style = "Beard (Full)"
	user.hair_color = "FFF"
	user.facial_hair_color = "FFF"
	user.update_hair()
