/obj/machinery/computer/prisoner/Destroy()
	if(inserted_prisoner_id)
		inserted_prisoner_id.forceMove(get_turf(src))
		inserted_prisoner_id = null
	return ..()

/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id))
		id_insert(user, I, inserted_prisoner_id)
		inserted_prisoner_id = I
	else
		return ..()
