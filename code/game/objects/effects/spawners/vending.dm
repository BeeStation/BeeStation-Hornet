/obj/effect/spawner/randomvend
	icon = 'icons/obj/vending.dmi'
	name = "spawn random vending machine"// THIS IS A PARENT, only use the subtype vendors
	desc = "Automagically transforms into a random vendor. If you see this while in a shift, please create a bug report."
	///whether it hacks the vendor on spawn currently used only by stinky mapedits
	var/hacked = FALSE

/obj/effect/spawner/randomvend/snack
	icon_state = "random_snack"
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomvend/snack/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/snack))
	var/obj/machinery/vending/snack/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL


/obj/effect/spawner/randomvend/cola
	icon_state = "random_cola"
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/randomvend/cola/Initialize(mapload)
	..()

	var/random_vendor = pick(subtypesof(/obj/machinery/vending/cola))
	var/obj/machinery/vending/cola/vend = new random_vendor(loc)
	vend.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL
