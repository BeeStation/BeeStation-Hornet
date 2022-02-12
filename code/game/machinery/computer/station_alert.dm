/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/stationalert

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/station_alert/Initialize(mapload)
	. = ..()
	GLOB.alert_consoles += src

/obj/machinery/computer/station_alert/Destroy()
	GLOB.alert_consoles -= src
	return ..()


/obj/machinery/computer/station_alert/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole")
		ui.open()

/obj/machinery/computer/station_alert/ui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	for(var/class in GLOB.alarms)
		data["alarms"][class] = list()
		for(var/area in GLOB.alarms[class])
			data["alarms"][class] += area

	return data

/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/home, cameras, obj/source)
	if(source.get_virtual_z_level() != get_virtual_z_level())
		return
	if(stat & (BROKEN))
		return

	var/list/our_sort = GLOB.alarms[class]
	for(var/areaname in our_sort)
		if (areaname == home.name)
			var/list/alarm = our_sort[areaname]
			var/list/sources = alarm[3]
			if (!(source in sources))
				sources += source
			ui_update()
			return TRUE

	var/obj/machinery/camera/cam = null
	var/list/our_cams = null
	if(cameras && islist(cameras))
		our_cams = cameras
		if (our_cams.len == 1)
			cam = our_cams[1]
	else if(cameras && istype(cameras, /obj/machinery/camera))
		cam = cameras
	our_sort[home.name] = list(home, (cam ? cam : cameras), list(source))
	ui_update()
	return TRUE

/obj/machinery/computer/station_alert/proc/freeCamera(area/home, obj/machinery/camera/cam)
	for(var/class in GLOB.alarms)
		var/our_area = GLOB.alarms[class][home.name]
		if(!our_area)
			continue
		var/cams = our_area[2] //Get the cameras
		if(!cams)
			continue
		if(islist(cams))
			cams -= cam
			if(length(cams) == 1)
				our_area[2] = cams[1]
		else
			our_area[2] = null
	ui_update()

/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
	if(stat & (BROKEN))
		return
	var/list/L = GLOB.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	ui_update()
	return !cleared

/obj/machinery/computer/station_alert/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	var/active_alarms = FALSE
	for(var/cat in GLOB.alarms)
		var/list/L = GLOB.alarms[cat]
		if(L.len)
			active_alarms = TRUE
	if(active_alarms)
		add_overlay("alert:2")
