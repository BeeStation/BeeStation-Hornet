/obj/item/shuttle_route_optimisation
	name = "Route Optimisation Upgrade"
	desc = "Used on a shuttle control console to calculate more efficient routes."
	icon = 'icons/obj/module.dmi'
	icon_state = "shuttledisk"
	force = 0
	throwforce = 8
	throw_speed = 3
	throw_range = 5
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON

/obj/item/shuttle_route_optimisation/attack_obj(obj/O, mob/living/user)
	. = ..()
	if(!istype(O, /obj/machinery/computer/custom_shuttle))
		return
	if (!user.transferItemToLoc(src, get_turf(O)))
		return
	var/obj/machinery/computer/custom_shuttle/link_comp = O
	link_comp.distance_multiplier = CLAMP(link_comp.distance_multiplier, 0, 0.8)
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
