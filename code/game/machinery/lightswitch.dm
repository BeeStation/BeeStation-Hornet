/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	layer = ABOVE_WINDOW_LAYER
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null
	var/screwdrivered = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_switch, 26)

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
	if(CONFIG_GET(flag/dark_unstaffed_departments))
		RegisterSignal(SSdcs, COMSIG_GLOB_POST_START, PROC_REF(turn_off))
	return

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER || screwdrivered)
		return
	var/state = "light-[area.lightswitch ? "on" : "off"]"
	. += mutable_appearance(icon, state)
	. += emissive_appearance(icon, state, layer, alpha = src.alpha)
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/machinery/light_switch/proc/turn_off()
	if(!is_station_level(z))//Only affects on-station lights
		return
	if(!area.lightswitch)//Lights already off
		return
	if(area.lights_always_start_on)//Public hallway or some other place where lights should start on
		return
	if(length(GLOB.roundstart_areas_lights_on))
		if(area in GLOB.roundstart_areas_lights_on)//Department is staffed, lights should shart on
			return
	area.lightswitch = FALSE //All checks failed, department is not staffed, lights get turned off

	for(var/obj/machinery/light_switch/L in GLOB.machines)
		if(L.area == area)
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
		to_chat(user, span_notice("You flick the switch but nothing happens!"))
		return
	area.lightswitch = !area.lightswitch
	play_click_sound("button")

	for(var/obj/machinery/light_switch/L in GLOB.machines)
		if(L.area == area)
			L.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

	area.power_change()

/obj/machinery/light_switch/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		screwdrivered = !screwdrivered
		user.visible_message(span_notice("[user] [screwdrivered ? "un" : ""]secures [name]."), \
		span_notice("You [screwdrivered ? "un" : ""]secure [name]."))
		I.play_tool_sound(src)
		update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)
		return
	if(I.tool_behaviour == TOOL_CROWBAR && screwdrivered)
		I.play_tool_sound(src)
		user.visible_message(span_notice("[user] pries [name] off the wall."),span_notice("You pry [name] off the wall."))
		new /obj/item/wallframe/light_switch(loc)
		qdel(src)
		return

/obj/machinery/light_switch/power_change()
	SHOULD_CALL_PARENT(FALSE)
	if(area == get_area(src))
		return ..()

/obj/machinery/light_switch/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		power_change()

/obj/machinery/light_switch/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("You begin manipulating [src]!"))
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
	pixel_shift = 26
