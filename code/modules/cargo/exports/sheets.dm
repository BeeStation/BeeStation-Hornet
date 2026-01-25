/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Hides

/datum/export/stack/skin/monkey
	cost = 50
	unit_name = "monkey hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/monkey = TRUE,
	)

/datum/export/stack/skin/human
	cost = 100
	unit_name = "piece"
	message = "of human skin"
	export_types = list(
		/obj/item/stack/sheet/animalhide/human = TRUE,
	)

/datum/export/stack/skin/goliath_hide
	cost = 200
	unit_name = "goliath hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/goliath_hide = TRUE,
	)

/datum/export/stack/skin/cat
	cost = 150
	unit_name = "cat hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/cat = TRUE,
	)

/datum/export/stack/skin/corgi
	cost = 200
	unit_name = "corgi hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/corgi = TRUE,
	)

/datum/export/stack/skin/lizard
	cost = 150
	unit_name = "lizard hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/lizard = TRUE,
	)

/datum/export/stack/skin/gondola
	cost = 5000
	unit_name = "gondola hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/gondola = TRUE,
	)

/datum/export/stack/skin/xeno
	cost = 500
	unit_name = "alien hide"
	export_types = list(
		/obj/item/stack/sheet/animalhide/xeno = TRUE,
	)

// Common materials.
// For base materials, see materials.dm

/datum/export/stack/plasteel
	cost = 155 // 2000u of plasma + 2000u of iron.
	message = "of plasteel"
	export_types = list(
		/obj/item/stack/sheet/plasteel = TRUE,
	)

// 1 glass + 0.5 iron, cost is rounded up.
/datum/export/stack/rglass
	cost = 8
	message = "of reinforced glass"
	export_types = list(
		/obj/item/stack/sheet/rglass = TRUE,
	)

/datum/export/stack/plastitanium
	cost = 325 // plasma + titanium costs
	message = "of plastitanium"
	export_types = list(
		/obj/item/stack/sheet/mineral/plastitanium = TRUE,
	)

/datum/export/stack/wood
	cost = 30
	unit_name = "wood plank"
	export_types = list(
		/obj/item/stack/sheet/wood = TRUE,
	)

/datum/export/stack/cardboard
	cost = 2
	message = "of cardboard"
	export_types = list(
		/obj/item/stack/sheet/cardboard = TRUE,
	)

/datum/export/stack/sandstone
	cost = 1
	unit_name = "block"
	message = "of sandstone"
	export_types = list(
		/obj/item/stack/sheet/mineral/sandstone = TRUE,
	)

/datum/export/stack/cable
	cost = 0.2
	unit_name = "cable piece"
	export_types = list(
		/obj/item/stack/cable_coil = TRUE,
	)

// Weird Stuff

/datum/export/stack/abductor
	cost = 1000
	message = "of alien alloy"
	export_types = list(
		/obj/item/stack/sheet/mineral/abductor = TRUE,
	)

