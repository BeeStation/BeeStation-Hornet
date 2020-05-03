/obj/item/grenade/empgrenade
	name = "classic EMP grenade"
	desc = "It is designed to wreak havoc on electronic systems."
	icon_state = "emp"
	item_state = "emp"

/obj/item/grenade/empgrenade/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	for(var/obj/machinery/light/L in range(10, src))
		L.on = 1
		L.break_light_tube()
	empulse(src, 4, 10)
	qdel(src)
