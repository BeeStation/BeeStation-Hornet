#define MULTIZ_PIPE_UP 1 ///Defines for determining which way a multiz disposal element should travel
#define MULTIZ_PIPE_DOWN 2 ///Defines for determining which way a multiz disposal element should travel


/obj/structure/disposalpipe/multiz
	name = "Disposal trunk that goes up"
	icon_state = "pipe-up"
	var/multiz_dir = MULTIZ_PIPE_UP ///Set the multiz direction of your trunk. 1 = up, 2 = down

/obj/structure/disposalpipe/multiz/can_enter_from_dir(fdir)
	switch (multiz_dir)
		if (MULTIZ_PIPE_UP)
			if (fdir == UP)
				return TRUE
		if (MULTIZ_PIPE_DOWN)
			if (fdir == DOWN)
				return TRUE
	return ..()

/obj/structure/disposalpipe/multiz/nextdir(obj/structure/disposalholder/H)
	if (H.dir & turn(dpdir, 180))
		switch (multiz_dir)
			if (MULTIZ_PIPE_UP)
				return UP
			if (MULTIZ_PIPE_DOWN)
				return DOWN
	return dpdir

/obj/structure/disposalpipe/multiz/down
	name = "Disposal trunk that goes down"
	icon_state = "pipe-down"
	multiz_dir = MULTIZ_PIPE_DOWN

#undef MULTIZ_PIPE_UP
#undef MULTIZ_PIPE_DOWN
