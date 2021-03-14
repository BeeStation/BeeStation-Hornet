/datum/outfit/battle_royale
	name = "Battle Royale Gear"

	uniform = /obj/item/clothing/under/color/random
	id = /obj/item/card/id/syndicate/anyone
	ears = /obj/item/radio/headset/headset_cent
	belt = /obj/item/pda
	back = /obj/item/pickaxe/harvesting_tool
	shoes = /obj/item/clothing/shoes/combat

/obj/item/pickaxe/harvesting_tool
	name = "Harvesting Tool"
	siemens_coefficient = 0

/obj/item/pickaxe/harvesting_tool/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure))
			var/obj/structure/S = A
			A.take_damage(80, BRUTE, "melee", 0)
