/obj/structure/closet/l3closet
	name = "level 3 biohazard gear closet"
	desc = "It's a storage unit for level 3 biohazard gear."
	icon_state = "bio"

/obj/structure/closet/l3closet/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/general(src)
	new /obj/item/clothing/head/bio_hood/general(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/closet/l3closet/virology
	icon_state = "bio_viro"

/obj/structure/closet/l3closet/virology/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/virology(src)
	new /obj/item/clothing/head/bio_hood/virology(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)

/obj/structure/closet/l3closet/virology/starting
	name = "level 3 biohazard research closet"
	desc = "It's a storage unit for level 3 biohazard gear. This one comes with extra research materials."

/obj/structure/closet/l3closet/virology/starting/PopulateContents()
	.=..()
	new /obj/item/storage/box/monkeycubes(src)
	if(CONFIG_GET(flag/allow_virologist))
		new /obj/item/book/manual/wiki/infections(src)
		new /obj/item/stack/sheet/mineral/plasma(src)
	else
		new /obj/item/gun/syringe (src)

/obj/structure/closet/l3closet/security
	icon_state = "bio_sec"

/obj/structure/closet/l3closet/security/PopulateContents()
	new /obj/item/clothing/suit/bio_suit/security(src)
	new /obj/item/clothing/head/bio_hood/security(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/closet/l3closet/janitor
	icon_state = "bio_jan"

/obj/structure/closet/l3closet/janitor/PopulateContents()
	new /obj/item/clothing/suit/bio_suit/janitor(src)
	new /obj/item/clothing/head/bio_hood/janitor(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/closet/l3closet/scientist
	icon_state = "bio_viro"

/obj/structure/closet/l3closet/scientist/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)

