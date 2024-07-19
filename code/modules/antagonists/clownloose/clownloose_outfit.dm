/datum/outfit/clownloose
	name = "Loose Clown"
	id = /obj/item/card/id/job/clown
	belt = /obj/item/modular_computer/tablet/pda/clown
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/banana_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	head = /obj/item/clothing/head/beret/cccaptain
	r_hand = /obj/item/gun/magic/staff/honk
	l_pocket = /obj/item/bikehorn
	back= /obj/item/storage/backpack/duffelbag/clown/cream_pie
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		/obj/item/stack/sheet/mineral/bananium/twenty,
		)

	implants = list(/obj/item/implant/sad_trombone)

	box = /obj/item/storage/box/survival/hug

/datum/outfit/clownloose/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names))
	H.dna.add_mutation(CLOWNMUT)
	ADD_TRAIT(H, TRAIT_NAIVE, JOB_TRAIT)
