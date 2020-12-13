//That's basically it. Wallframe handles most of this. Thank you wall frame
/obj/item/wallframe/shuttle_weapon
	name = "Shuttle weapon placer"
	desc = "A mount for placing shuttle weapons onto ships."
	//Typepath of the weapon to place
	result_path = /obj/machinery/shuttle_weapon

//Overriding the entire proc just to change 1 line. yikes
/obj/item/wallframe/shuttle_weapon/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
		user.visible_message("[user.name] attaches [src] to the wall.",
			"<span class='notice'>You attach [src] to the wall.</span>",
			"<span class='italics'>You hear clicking.</span>")
		var/ndir = get_dir(on_wall,user)
		if(inverse)
			ndir = turn(ndir, 180)

		var/obj/O = new result_path(on_wall, ndir, TRUE)
		if(pixel_shift)
			switch(ndir)
				if(NORTH)
					O.pixel_y = pixel_shift
				if(SOUTH)
					O.pixel_y = -pixel_shift
				if(EAST)
					O.pixel_x = pixel_shift
				if(WEST)
					O.pixel_x = -pixel_shift
		after_attach(O)

	qdel(src)
