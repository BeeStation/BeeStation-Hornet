//Meteor Shields
//Originally a station goal, only the code for the meteor shields was kept

/obj/machinery/computer/sat_control
	name = "satellite control"
	desc = "Used to control the satellite network."
	circuit = /obj/item/circuitboard/computer/sat_control
	var/notice

/obj/machinery/computer/sat_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/sat_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteControl")
		ui.open()
		ui.set_autoupdate(TRUE) // Satellite stats (could probably be refactored to update when satellite status changes)

/obj/machinery/computer/sat_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE

/obj/machinery/computer/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/S in GLOB.machines)
		if(S.id == id && S.get_virtual_z_level() == get_virtual_z_level())
			S.toggle()

/obj/machinery/computer/sat_control/ui_data()
	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/S in GLOB.machines)
		data["satellites"] += list(list(
			"id" = S.id,
			"active" = S.active,
			"mode" = S.mode
		))
	data["notice"] = notice

/obj/machinery/satellite
	name = "\improper Defunct Satellite"
	desc = ""
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	var/mode = "NTPROBEV0.8"
	var/active = FALSE
	var/static/gid = 0
	var/id = 0

/obj/machinery/satellite/Initialize(mapload)
	. = ..()
	id = gid++

/obj/machinery/satellite/interact(mob/user)
	toggle(user)

/obj/machinery/satellite/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	active = anchorvalue
	if(anchorvalue)
		animate(src, pixel_y = 2, time = 10, loop = -1)
	else
		animate(src, pixel_y = 0, time = 10)
	update_icon()

/obj/machinery/satellite/proc/toggle(mob/user)
	if(!active && !isinspace())
		if(user)
			to_chat(user, span_warning("You can only activate [src] in space."))
		return FALSE
	if(user)
		to_chat(user, span_notice("You [active ? "deactivate": "activate"] [src]."))
	set_anchored(!anchored)
	return TRUE

/obj/machinery/satellite/update_icon()
	icon_state = active ? "sat_active" : "sat_inactive"

/obj/machinery/satellite/multitool_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("// NTSAT-[id] // Mode : [active ? "PRIMARY" : "STANDBY"] //[(obj_flags & EMAGGED) ? "DEBUG_MODE //" : ""]"))
	return TRUE

/obj/item/meteor_shield
	name = "\improper Meteor Shield Satellite Deploy Capsule"
	desc = "A bluespace capsule which a single unit of meteor shield satellite is compressed within. If you activate this capsule, a meteor shield satellite will pop out. You still need to install these."
	icon = 'icons/obj/mining.dmi'
	icon_state = "capsule"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/meteor_shield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, /obj/machinery/satellite/meteor_shield, time_to_deploy = 0)

/obj/machinery/satellite/meteor_shield
	name = "\improper Meteor Shield Satellite"
	desc = "A meteor point-defense satellite."
	mode = "M-SHIELD"
	var/kill_range = 14
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor


/obj/machinery/satellite/meteor_shield/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 0)

/obj/machinery/satellite/meteor_shield/proc/space_los(meteor)
	for(var/turf/T in get_line(src,meteor))
		if(!isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/satellite/meteor_shield/HasProximity(atom/movable/AM)
	if(istype(AM, /obj/effect/meteor))
		if(!(obj_flags & EMAGGED) && space_los(AM))
			Beam(get_turf(AM),icon_state="sat_beam", time = 5)
			qdel(AM)

/obj/machinery/satellite/meteor_shield/toggle(user)
	if(!..(user))
		return FALSE

	proximity_monitor.set_range(active ? kill_range : 0)

	if(obj_flags & EMAGGED)
		if(active)
			change_meteor_chance(2)
		else
			change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/proc/change_meteor_chance(mod)
	var/datum/round_event_control/E = locate(/datum/round_event_control/meteor_wave) in SSevents.control
	if(E)
		E.weight *= mod

/obj/machinery/satellite/meteor_shield/Destroy()
	. = ..()
	if(active && (obj_flags & EMAGGED))
		change_meteor_chance(0.5)

/obj/machinery/satellite/meteor_shield/on_emag(mob/user)
	..()
	to_chat(user, span_notice("You access the satellite's debug mode, increasing the chance of meteor strikes."))
	if(active)
		change_meteor_chance(2)
