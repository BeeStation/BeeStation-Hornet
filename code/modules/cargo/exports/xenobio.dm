/datum/export/slime

/datum/export/slime/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/costfromparent = ..()
	if (istype(O,/obj/item/slime_extract))
		var/obj/item/slime_extract/slimething = O
		if (slimething.sparkly)
			return costfromparent*2

/datum/export/slime/grey
	cost = CARGO_CRATE_VALUE * 0.05
	unit_name = "grey slime core"
	export_types = list(/obj/item/slime_extract/grey)

/datum/export/slime/common
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "common slime core"
	export_types = list(/obj/item/slime_extract/metal,/obj/item/slime_extract/orange,/obj/item/slime_extract/purple,/obj/item/slime_extract/blue)

/datum/export/slime/uncommon
	cost = CARGO_CRATE_VALUE * 0.5
	unit_name = "uncommon slime core"
	export_types = list(/obj/item/slime_extract/silver,/obj/item/slime_extract/darkblue,/obj/item/slime_extract/darkpurple,/obj/item/slime_extract/yellow)

/datum/export/slime/rare
	cost = CARGO_CRATE_VALUE * 0.28
	unit_name = "rare slime core"
	export_types = list(/obj/item/slime_extract/gold,/obj/item/slime_extract/green,/obj/item/slime_extract/red,/obj/item/slime_extract/pink)

/datum/export/slime/hypercharged
	cost = CARGO_CRATE_VALUE * 1.2
	unit_name = "hypercharged slime core"
	export_types = list(/obj/item/stock_parts/cell/high/slime/hypercharged)

/datum/export/slime/epic
	cost = CARGO_CRATE_VALUE * 0.44
	unit_name = "epic slime core"
	export_types = list(/obj/item/slime_extract/black,/obj/item/slime_extract/cerulean,/obj/item/slime_extract/oil,/obj/item/slime_extract/sepia,/obj/item/slime_extract/pyrite,/obj/item/slime_extract/adamantine,/obj/item/slime_extract/lightpink,/obj/item/slime_extract/bluespace)

/datum/export/slime/rainbow
	cost = CARGO_CRATE_VALUE
	unit_name = "rainbow slime core"
	export_types = list(/obj/item/slime_extract/rainbow)
