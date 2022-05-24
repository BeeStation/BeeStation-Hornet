/obj/item/implant/explosive/siege
	name = "siege implant"
	desc = "Robust Corp RX-70 equipment denial system."

/obj/item/implant/explosive/siege/on_mob_death(mob/living/L, gibbed)
	L.dust()

/obj/item/implant/explosive/siege/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-70 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Disintegrates user<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a powerful compact, acid that activates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Disintegrates user<BR>
				"}
	return dat

/obj/item/implant/explosive/siege/activate(mob/living/L)
	L.dust()

/obj/item/implant/explosive/siege/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, type))
			qdel(src)
			return 1
