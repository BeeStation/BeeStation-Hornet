/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	layer = ABOVE_WINDOW_LAYER
	// Small light so emissive is visible even in full blackness
	light_range = 1
	light_power = 0.05
	light_on = TRUE
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null
	var/screwdrivered = FALSE

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

	update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	return

/obj/machinery/light_switch/LateInitialize()
	if(!is_station_level(z))
		return
	var/area/source_area = get_area(get_turf(src))
	if(source_area.lights_always_start_on)
		return
	turn_off()

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER || screwdrivered)
		return
	var/state = "light-[area.lightswitch ? "on" : "off"]"
	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, alpha = src.alpha)

/obj/machinery/light_switch/proc/turn_off()
	if(!area.lightswitch)
		return
	area.lightswitch = FALSE

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

	area.power_change()

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."
	if(screwdrivered)
		. += "Its panel appears to be unscrewed."
		. += "It looks like it could be <b>pried</b> off the wall."

/obj/machinery/light_switch/interact(mob/user)
	. = ..()
	if(screwdrivered)
		to_chat(user, "<span class='notice'>You flick the switch but nothing happens!</span>")
		return
	area.lightswitch = !area.lightswitch
	play_click_sound("button")

	for(var/obj/machinery/light_switch/L in area)
		L.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

	area.power_change()

/obj/machinery/light_switch/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		screwdrivered = !screwdrivered
		user.visible_message("<span class='notice'>[user] [screwdrivered ? "un" : ""]secures [name].</span>", \
		"<span class='notice'>You [screwdrivered ? "un" : ""]secure [name].</span>")
		I.play_tool_sound(src)
		update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)
		return
	if(I.tool_behaviour == TOOL_CROWBAR && screwdrivered)
		I.play_tool_sound(src)
		user.visible_message("<span class='notice'>[user] pries [name] off the wall.</span>","<span class='notice'>You pry [name] off the wall.</span>")
		new /obj/item/wallframe/light_switch(loc)
		qdel(src)
		return

/obj/machinery/light_switch/power_change()
	if(area == get_area(src))
		if(powered(AREA_USAGE_LIGHT))
			set_machine_stat(machine_stat & ~NOPOWER)
		else
			set_machine_stat(machine_stat | NOPOWER)

		update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

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

/obj/item/wallframe/light_switch
	name = "light switch frame"
	desc = "Used for building wall-mounted light switches."
	icon_state = "lightswitch"
	result_path = /obj/machinery/light_switch
	pixel_shift = -26
