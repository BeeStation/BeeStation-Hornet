/obj/structure/closet/syndicate
	name = "armory closet"
	desc = "Why is this here?"
	icon_state = "syndicate"

/obj/structure/closet/syndicate/personal
	desc = "It's a personal storage unit for operative gear."

/obj/structure/closet/syndicate/personal/PopulateContents()
	..()
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/radio/headset/syndicate(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/clothing/glasses/night(src)

/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for a Syndicate boarding party."

/obj/structure/closet/syndicate/nuclear/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/backpack/duffelbag/syndie/med(src)
	new /obj/item/modular_computer/tablet/pda/preset/syndicate(src)

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

/obj/structure/closet/syndicate/resources/PopulateContents()
	..()
	var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK


	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/paper/paper = new /obj/item/paper(src)
		paper.name = "\improper IOU"
		paper.add_raw_text("Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!")
		paper.update_appearance()

	//Iron (common ore)
	if(pickednum >= 2)
		new /obj/item/stack/sheet/iron(src, rand(common_min, common_max))

	//Glass (common ore)
	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

	//Plasteel (common ore) Because it has a million more uses then plasma
	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//Plasma (rare ore)
	if(pickednum >= 15)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//Silver (rare ore)
	if(pickednum >= 20)
		new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//Gold (rare ore)
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//Uranium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//Titanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

	//Plastitanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

	//Diamond (rare HONK)
	if(pickednum >= 45)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

/obj/structure/closet/syndicate/resources/everything/PopulateContents()
	new /obj/item/storage/box/material(src)
	new /obj/item/storage/box/material(src)
