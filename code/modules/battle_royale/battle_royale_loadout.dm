/datum/outfit/battle_royale
	name = "Battle Royale Gear"

	uniform = /obj/item/clothing/under/color/random
	id = /obj/item/card/id/syndicate/anyone
	ears = /obj/item/radio/headset/headset_cent
	belt = /obj/item/pda
	back = /obj/item/pickaxe/harvesting_tool
	shoes = /obj/item/clothing/shoes/combat
	glasses = /obj/item/clothing/glasses/night

/obj/item/pickaxe/harvesting_tool
	name = "Harvesting Tool"
	siemens_coefficient = 0

/obj/item/pickaxe/harvesting_tool/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(A, /obj/structure))
		var/obj/structure/S = A
		S.take_damage(80, BRUTE, "melee", 0, armour_penetration = 100)
