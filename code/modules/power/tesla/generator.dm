/obj/machinery/the_singularitygen/tesla
	name = "energy ball generator"
	desc = "Makes the wardenclyffe look like a child's plaything when shot with a particle accelerator."
	icon = 'icons/obj/tesla_engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/anomaly/energy_ball

/obj/machinery/the_singularitygen/tesla/tesla_act(power, tesla_flags)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		energy += power

/obj/machinery/the_singularitygen/tesla/rusted
	name = "old energy ball generator"
	desc = "Makes the wardenclyffe look like a child's plaything when shot with a particle accelerator."
	anchored = TRUE
	can_be_unanchored = FALSE
	creation_type = /obj/anomaly/energy_ball/quiet

/obj/machinery/the_singularitygen/tesla/rusted/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This one is practically rusted to the floor!.</span>"

/obj/machinery/the_singularitygen/tesla/rusted/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		return
	. = ..()



