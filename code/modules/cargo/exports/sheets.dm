// ============================================================================
// PLASMA STATION EXPORTS
// This station exists for plasma research and mining. Plasma and its derivative
// products are the primary revenue stream, along with bluespace crystals.
// For base stack export handling, see materials.dm
// ============================================================================

/datum/export/stack
	unit_name = "sheet"

/datum/export/stack/get_amount(obj/O)
	var/obj/item/stack/S = O
	if(istype(S))
		return S.amount
	return 0

// Plasma ore (unrefined)
/datum/export/stack/plasma_ore
	cost = 75
	unit_name = "plasma ore chunk"
	export_types = list(
		/obj/item/stack/ore/plasma = TRUE,
	)

// Refined plasma sheets - the station's primary export
/datum/export/stack/plasma
	cost = 150
	message = "of plasma"
	export_types = list(
		/obj/item/stack/sheet/mineral/plasma = TRUE,
	)

// Plasma Products

/datum/export/stack/plasteel
	cost = 155 // 2000u of plasma + 2000u of iron.
	message = "of plasteel"
	export_types = list(
		/obj/item/stack/sheet/plasteel = TRUE,
	)

/datum/export/stack/plasmaglass
	cost = 80 // plasma + glass
	message = "of plasma glass"
	export_types = list(
		/obj/item/stack/sheet/plasmaglass = TRUE,
	)

/datum/export/stack/plasmarglass
	cost = 85 // plasma + glass + iron
	message = "of reinforced plasma glass"
	export_types = list(
		/obj/item/stack/sheet/plasmarglass = TRUE,
	)

/datum/export/stack/plastitanium
	cost = 325 // plasma + titanium costs
	message = "of plastitanium"
	export_types = list(
		/obj/item/stack/sheet/mineral/plastitanium = TRUE,
	)

/datum/export/stack/plastitaniumglass
	cost = 175 // plasma + titanium + glass
	message = "of plastitanium glass"
	export_types = list(
		/obj/item/stack/sheet/plastitaniumglass = TRUE,
	)

// Bluespace Crystals

/datum/export/stack/bluespace_crystal
	cost = 300
	unit_name = "bluespace crystal"
	export_types = list(
		/obj/item/stack/ore/bluespace_crystal = TRUE,
	)

/datum/export/stack/bluespace_crystal_artificial
	cost = 150
	unit_name = "synthetic bluespace crystal"
	export_types = list(
		/obj/item/stack/ore/bluespace_crystal/artificial = TRUE,
	)

/datum/export/stack/bluespace_crystal_refined
	cost = 500
	unit_name = "refined bluespace crystal"
	export_types = list(
		/obj/item/stack/ore/bluespace_crystal/refined = TRUE,
	)

