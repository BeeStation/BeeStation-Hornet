/datum/crafting_recipe/upgraded_gauze
	name = "Improved Gauze"
	result = /obj/item/stack/medical/gauze/adv/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/space_cleaner/sterilizine = 10
	)
	category = CAT_MEDICAL

/datum/crafting_recipe/bruise_pack
	name = "Bruise Pack"
	result = /obj/item/stack/medical/bruise_pack/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/medicine/styptic_powder = 20
	)
	category = CAT_MEDICAL

/datum/crafting_recipe/burn_pack
	name = "Burn Ointment"
	result = /obj/item/stack/medical/ointment/one
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 1,
		/datum/reagent/medicine/silver_sulfadiazine = 20
	)
	category = CAT_MEDICAL

/datum/crafting_recipe/tourniquet
	name = "Tourniquet"
	result = /obj/item/stack/medical/tourniquet
	time = 1 SECONDS
	reqs = list(
		/obj/item/stack/medical/gauze = 3,
		/obj/item/stack/sheet/wood = 1,
	)
	category = CAT_MEDICAL
