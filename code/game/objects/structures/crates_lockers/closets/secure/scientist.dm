/obj/structure/closet/secure_closet/RD
	name = "\proper research director's locker"
	req_access = list(ACCESS_RD)
	icon_state = "rd"

/obj/structure/closet/secure_closet/RD/populate_contents_immediate()
	..()
	new /obj/item/clothing/suit/armor/reactive/teleport(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/card/id/departmental_budget/sci(src)

/obj/structure/closet/secure_closet/RD/PopulateContents()
	..()
	new /obj/item/storage/box/suitbox/rd(src)
	new /obj/item/clothing/suit/toggle/labcoat/research_director(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/radio/headset/heads/research_director(src)

	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/tank/internals/air(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/RD(src)

	new /obj/item/storage/box/radiokey/sci(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/computer_hardware/hard_drive/role/rd(src)
	new /obj/item/storage/lockbox/medal/sci(src)
	new /obj/item/circuitboard/machine/techfab/department/science(src)

	// prioritized items
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/clothing/glasses/hud/diagnostic(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/door_remote/research_director(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/gun/energy/e_gun/mini/heads(src)

/obj/item/storage/box/suitbox/rd
	name = "compression box of research director outfits"

/obj/item/storage/box/suitbox/rd/PopulateContents()
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt/skirt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/vest(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt(src)
	new /obj/item/clothing/head/beret/sci(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
