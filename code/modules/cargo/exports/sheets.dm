/datum/export/stack
	abstract_type = /datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Hides

/datum/export/stack/skin/monkey
	cost = CARGO_CRATE_VALUE * 0.1
	unit_name = "monkey hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/monkey = TRUE,
	)

/datum/export/stack/skin/human
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "piece"
	message = "of human skin"
	export_types = list(
		/obj/item/stack/sheet/animalhide/human = TRUE,
	)

/datum/export/stack/skin/goliath_hide
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "goliath hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/goliath_hide = TRUE,
	)

/datum/export/stack/skin/cat
	cost = CARGO_CRATE_VALUE * 0.3
	unit_name = "cat hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/cat = TRUE,
	)

/datum/export/stack/skin/corgi
	cost = CARGO_CRATE_VALUE * 0.4
	unit_name = "corgi hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/corgi = TRUE,
	)

/datum/export/stack/skin/lizard
	cost = CARGO_CRATE_VALUE * 0.3
	unit_name = "lizard hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/lizard = TRUE,
	)

/datum/export/stack/skin/gondola
	cost = CARGO_CRATE_VALUE * 8
	unit_name = "gondola hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/gondola = TRUE,
	)

/datum/export/stack/skin/xeno
	cost = CARGO_CRATE_VALUE
	unit_name = "alien hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/xeno = TRUE,
	)

// Common materials.
// For base materials, see materials.dm

/datum/export/stack/plasteel
	cost = CARGO_CRATE_VALUE * 0.41 // 2000u of plasma + 2000u of metal.
	message = "of plasteel"
	export_types = list(
		/obj/item/stack/sheet/plasteel = TRUE,
	)

// 1 glass + 0.5 iron, cost is rounded up.
/datum/export/stack/rglass
	cost = CARGO_CRATE_VALUE * 0.04
	message = "of reinforced glass"
	export_types = list(
		/obj/item/stack/sheet/rglass = TRUE,
	)

/datum/export/stack/plastitanium
	cost = CARGO_CRATE_VALUE * 0.65 // plasma + titanium costs
	message = "of plastitanium"
	export_types = list(
		/obj/item/stack/sheet/mineral/plastitanium = TRUE,
	)

/datum/export/stack/wood
	cost = CARGO_CRATE_VALUE * 0.05
	unit_name = "wood plank"
	export_types = list(
		/obj/item/stack/sheet/wood = TRUE,
	)

/datum/export/stack/cloth
	cost = CARGO_CRATE_VALUE * 0.01
	message = "rolls of cloth"
	export_types = list(/obj/item/stack/sheet/cotton/cloth)

/datum/export/stack/durathread
	cost = CARGO_CRATE_VALUE * 0.35
	message = "rolls of durathread"
	export_types = list(/obj/item/stack/sheet/cotton/durathread)

/datum/export/stack/cardboard
	cost = CARGO_CRATE_VALUE * 0.01
	message = "of cardboard"
	export_types = list(
		/obj/item/stack/sheet/cardboard = TRUE,
	)

/datum/export/stack/sandstone
	cost = CARGO_CRATE_VALUE * 0.005
	unit_name = "block"
	message = "of sandstone"
	export_types = list(
		/obj/item/stack/sheet/mineral/sandstone = TRUE,
	)

/datum/export/stack/cable
	cost = CARGO_CRATE_VALUE * 0.001
	unit_name = "cable piece"
	export_types = list(
		/obj/item/stack/cable_coil = TRUE,
	)

/*
/datum/export/stack/pizza
	cost = CARGO_CRATE_VALUE * 0.06
	unit_name = "of sheetza"
	export_types = list(/obj/item/stack/sheet/pizza)
*/

/datum/export/stack/meat
	cost = CARGO_CRATE_VALUE * 0.04
	unit_name = "of meat"
	export_types = list(/obj/item/stack/sheet/meat)

// Weird Stuff

/datum/export/stack/abductor
	cost = CARGO_CRATE_VALUE * 2
	message = "of alien alloy"
	export_types = list(
		/obj/item/stack/sheet/mineral/abductor = TRUE,
	)
