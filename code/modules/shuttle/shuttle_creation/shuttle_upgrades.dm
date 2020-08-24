/obj/item/shuttle_route_optimisation
	name = "Route Optimisation Upgrade"
	desc = "Used on a custom shuttle control console to calculate more efficient routes."
	icon = 'icons/obj/module.dmi'
	icon_state = "shuttledisk"
	force = 0
	throwforce = 8
	throw_speed = 3
	throw_range = 5
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	var/upgrade_amount = 0.8

/obj/item/shuttle_route_optimisation/hyperlane
	name = "Bluespace Hyperlane Calculator"
	desc = "Used on a custom shuttle control console to allow for the following of bluespace hyperlanes, increasing the efficiency of the shuttle."
	icon_state = "shuttledisk_better"
	upgrade_amount = 0.6

/obj/item/shuttle_route_optimisation/void
	name = "Voidspace Route Calculator"
	desc = "Used on a custom shuttle control console to allow it to navigate into voidspace, making the routes almost instant."
	icon_state = "shuttledisk_void"
	upgrade_amount = 0.2

/obj/item/shuttle_route_optimisation/attack_obj(obj/O, mob/living/user)
	. = ..()
	if(!istype(O, /obj/machinery/computer))
		return
	if(!istype(O, /obj/machinery/computer/custom_shuttle))
		to_chat(user, "<span class='warning'>This upgrade only works on a custom shuttle flight console.</span>")
		return
	if (!user.transferItemToLoc(src, get_turf(O)))
		return
	var/obj/machinery/computer/custom_shuttle/link_comp = O
	link_comp.distance_multiplier = CLAMP(link_comp.distance_multiplier, 0, upgrade_amount)
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	to_chat(usr, "<span class='notice'>You insert the disk into the flight computer, allowing for routes to be [upgrade_amount]x the original distance.</span>")
