/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	layer = ABOVE_WINDOW_LAYER
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)

	if(!name)
		name = "light switch ([area.name])"

	update_icon()

/obj/machinery/light_switch/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "light-p"
	else
		if(area.lightswitch)
			icon_state = "light1"
		else
			icon_state = "light0"

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."

/obj/machinery/light_switch/interact(mob/user)
	. = ..()

	area.lightswitch = !area.lightswitch
	play_click_sound("button")
	area.update_icon()

	for(var/obj/machinery/light_switch/L in area)
		L.update_icon()

	area.power_change()

/obj/machinery/light_switch/power_change()
	if(area == get_area(src))
		if(powered(AREA_USAGE_LIGHT))
			set_machine_stat(machine_stat & ~NOPOWER)
		else
			set_machine_stat(machine_stat | NOPOWER)

		update_icon()

/obj/machinery/light_switch/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		power_change()

/obj/machinery/light_switch/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, "<span class='brass'>You begin manipulating [src]!</span>")
	if(do_after(eminence, 20, target=get_turf(eminence)))
		interact(eminence)

/obj/machinery/light_switch/tcomms
	name = "Server Room light switch"
	area = /area/tcommsat/server
