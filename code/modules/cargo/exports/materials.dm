/datum/export/stack
	cost = 0	// This is defined later based on cusgenerated prices
	export_category = EXPORT_CARGO
	include_subtypes = TRUE
	export_types = list(/obj/item/stack)

/datum/export/stack/get_amount(obj/item/stack/exported)
	if(!exported.amount)
		return 0
	if(!isitem(exported))
		return 0

	return exported.amount
/*
/datum/export/stack/bananium
	cost = 1000
	material_id = /datum/material/bananium
	message = "cm3 of bananium"

/datum/export/stack/diamond
	cost = 500
	material_id = /datum/material/diamond
	message = "cm3 of diamonds"

/datum/export/stack/plasma
	cost = 200
	material_id = /datum/material/plasma
	message = "cm3 of plasma"

/datum/export/stack/uranium
	cost = 100
	material_id = /datum/material/uranium
	message = "cm3 of uranium"

/datum/export/stack/gold
	cost = 125
	material_id = /datum/material/gold
	message = "cm3 of gold"

/datum/export/stack/copper
	cost = 15
	material_id = /datum/material/copper
	message = "cm3 of copper"

/datum/export/stack/silver
	cost = 50
	material_id = /datum/material/silver
	message = "cm3 of silver"

/datum/export/stack/titanium
	cost = 125
	material_id = /datum/material/titanium
	message = "cm3 of titanium"

/datum/export/stack/adamantine
	cost = 500
	material_id = /datum/material/adamantine
	message = "cm3 of adamantine"

/datum/export/stack/bscrystal
	cost = 300
	message = "of bluespace crystals"
	material_id = /datum/material/bluespace

/datum/export/stack/plastic
	cost = 25
	message = "cm3 of plastic"
	material_id = /datum/material/plastic

/datum/export/stack/iron
	cost = 5
	message = "cm3 of metal"
	material_id = /datum/material/iron
	export_types = list(
		/obj/item/stack/sheet/iron, /obj/item/stack/tile/iron,
		/obj/item/stack/rods, /obj/item/stack/ore, /obj/item/coin)

/datum/export/stack/glass
	cost = 5
	message = "cm3 of glass"
	material_id = /datum/material/glass
	export_types = list(/obj/item/stack/sheet/glass, /obj/item/stack/ore,
		/obj/item/shard)
*/
