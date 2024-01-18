#define SCAN_COOLDOWN (2 SECONDS)

/datum/computer_file/program/radar //generic parent that handles most of the process
	filename = "genericfinder"
	filedesc = "debug_finder"
	category = PROGRAM_CATEGORY_CREW
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
	program_icon_state = "radarntos"
	requires_ntnet = TRUE
	available_on_ntnet = FALSE
	usage_flags = PROGRAM_LAPTOP | PROGRAM_TABLET
	network_destination = "tracking program"
	size = 5
	tgui_id = "NtosRadar"
	///List of trackable entities. Updated by the scan() proc.
	var/list/objects
	///Ref of the last trackable object selected by the user in the tgui window. Updated in the ui_act() proc.
	var/atom/selected
	///Used to store when the next scan is available. Updated by the scan() proc.
	var/next_scan = 0
	///Used to keep track of the last value program_icon_state was set to, to prevent constant unnecessary update_icon() calls
	var/last_icon_state = ""
	///Used by the tgui interface, themed NT or Syndicate.
	var/arrowstyle = "ntosradarpointer.png"
	///Used by the tgui interface, themed for NT or Syndicate colors.
	var/pointercolor = "green"
	///tracks the target between z-level groups (i.e. Station v.s. Lavaland)
	var/tracks_grand_z = FALSE
	COOLDOWN_DECLARE(last_scan)

/datum/computer_file/program/radar/on_start(mob/living/user)
	. = ..()
	if(.)
		START_PROCESSING(SSfastprocess, src)
		return
	return FALSE

/datum/computer_file/program/radar/kill_program(forced = FALSE)
	objects = list()
	selected = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/radar/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/radar/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/radar_assets),
	)

/datum/computer_file/program/radar/ui_data(mob/user)
	var/list/data = list()
	// PDAs should not have full radar capabilities
	data["full_capability"] = !istype(computer, /obj/item/modular_computer/tablet/pda)
	data["selected"] = selected
	data["objects"] = list()
	data["scanning"] = (world.time < next_scan)
	for(var/list/i in objects)
		var/list/objectdata = list(
			ref = i["ref"],
			name = i["name"],
		)
		data["object"] += list(objectdata)

	data["target"] = list()
	var/list/trackinfo = track()
	if(trackinfo)
		data["target"] = trackinfo
	return data

/datum/computer_file/program/radar/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("selecttarget")
			selected = params["ref"]
			return TRUE
		if("scan")
			scan()
			return TRUE

/**
  *Updates tracking information of the selected target.
  *
  *The track() proc updates the entire set of information about the location
  *of the target, including whether the Ntos window should use a pinpointer
  *crosshair over the up/down arrows, or none in favor of a rotating arrow
  *for far away targets. This information is returned in the form of a list.
  *
*/
#define Z_RESULT_TOO_FAR 1 // Station v.s. Lavaland
#define Z_RESULT_SAME_Z 0 // Station 1st floor v.s. Station 5th floor

/datum/computer_file/program/radar/proc/track()
	var/atom/movable/signal = find_atom()
	if(!trackable(signal))
		return

	var/turf/here_turf = (get_turf(computer))
	var/turf/target_turf = (get_turf(signal))
	var/use_rotate = FALSE
	var/rotate_angle = 0
	var/pointer_z = ""
	var/locx = (target_turf.x - here_turf.x) + 24
	var/locy = (here_turf.y - target_turf.y) + 24
	var/dist = get_dist_euclidian(here_turf, target_turf)

	// this stores the z-value difference
	var/z_comparison_result_value
	// this stores if here and target is too far or near
	var/pin_grand_z_result = Z_RESULT_SAME_Z

	// getting z result first
	var/here_zlevel = here_turf.get_virtual_z_level()
	var/there_zlevel = target_turf.get_virtual_z_level()
	z_comparison_result_value = here_zlevel-there_zlevel // neg-val: above / posi-val: below

	if(abs(z_comparison_result_value)) // different z. now should check if it's too far
		pin_grand_z_result = compare_z(here_zlevel, there_zlevel)
		if(isnull(pin_grand_z_result)) // null: no good to track z levels
			return
		else if(!pin_grand_z_result) // FALSE: z-levels are in different groups. (Station v.s. Lavaland)
			if(!tracks_grand_z)
				return // do not track this
			pin_grand_z_result = Z_RESULT_TOO_FAR
		else // TRUE: z-levels are in the same group (i.e. multi-floored station)
			pin_grand_z_result = Z_RESULT_SAME_Z

		if(z_comparison_result_value < 0)
			pointer_z = "caret-up"
		else if(z_comparison_result_value > 0)
			pointer_z = "caret-down"

	if(dist > 24 || istype(computer, /obj/item/modular_computer/tablet/pda))
		use_rotate = TRUE
		rotate_angle = round(get_angle(here_turf, target_turf))

	var/list/trackinfo = list(
		"locx" = locx,
		"locy" = locy,
		"locz_string" = z_comparison_result_value<0 ? "Z+[z_comparison_result_value*-1]" : (z_comparison_result_value>0 ? "Z[z_comparison_result_value*-1]" : "Z±0"),
		"pin_grand_z_result" = pin_grand_z_result,
		"use_rotate" = use_rotate,
		"rotate_angle" = rotate_angle,
		"arrowstyle" = arrowstyle,
		"color" = pointercolor,
		"pointer_z" = pointer_z,
		"gpsx" = target_turf.x,
		"gpsy" = target_turf.y,
		"gpsz" = there_zlevel,
		"dist" = round(dist),
		)

	return trackinfo

#undef Z_RESULT_TOO_FAR
#undef Z_RESULT_SAME_Z

/**
  *
  *Checks the trackability of the selected target.
  *
  *If the target is on the computer's Z level, or both are on station Z
  *levels, and the target isn't untrackable, return TRUE.
  *Arguments:
  **arg1 is the atom being evaluated.
*/
/datum/computer_file/program/radar/proc/trackable(atom/movable/signal)
	return checks_trackable_core(computer, signal, tracks_grand_z, JAMMER_PROTECTION_SENSOR_NETWORK)

/**
  *
  *Runs a scan of all the trackable atoms.
  *
  *Checks each entry in the GLOB of the specific trackable atoms against
  *the track() proc, and fill the objects list with lists containing the
  *atoms' names and REFs. The objects list is handed to the tgui screen
  *for displaying to, and being selected by, the user. A two second
  *sleep is used to delay the scan, both for thematical reasons as well
  *as to limit the load players may place on the server using these
  *somewhat costly loops.
*/
/datum/computer_file/program/radar/proc/scan()
	return

/**
  *
  *Finds the atom in the appropriate list that the `selected` var indicates
  *
  *The `selected` var holds a REF, which is a string. A mob REF may be
  *something like "mob_209". In order to find the actual atom, we need
  *to search the appropriate list for the REF string. This is dependant
  *on the program (Lifeline uses GLOB.human_list, while Fission360 uses
  *GLOB.poi_list), but the result will be the same; evaluate the string and
  *return an atom reference.
*/
/datum/computer_file/program/radar/proc/find_atom()
	return

//We use SSfastprocess for the program icon state because it runs faster than process_tick() does.
/datum/computer_file/program/radar/process()
	if(computer.active_program != src)
		STOP_PROCESSING(SSfastprocess, src) //We're not the active program, it's time to stop.
		return
	if(!selected)
		return

	var/atom/movable/signal = find_atom()
	if(!trackable(signal))
		program_icon_state = "[initial(program_icon_state)]lost"
		if(last_icon_state != program_icon_state)
			computer.update_icon()
			last_icon_state = program_icon_state
		return

	var/here_turf = get_turf(computer)
	var/target_turf = get_turf(signal)
	var/trackdistance = get_dist_euclidian(here_turf, target_turf)
	switch(trackdistance)
		if(0)
			program_icon_state = "[initial(program_icon_state)]direct"
		if(1 to 12)
			program_icon_state = "[initial(program_icon_state)]close"
		if(13 to 24)
			program_icon_state = "[initial(program_icon_state)]medium"
		if(25 to INFINITY)
			program_icon_state = "[initial(program_icon_state)]far"

	if(last_icon_state != program_icon_state)
		computer.update_icon()
		last_icon_state = program_icon_state
	computer.setDir(get_dir(here_turf, target_turf))

//We can use process_tick to restart fast processing, since the computer will be running this constantly either way.
/datum/computer_file/program/radar/process_tick()
	if(computer.active_program == src)
		START_PROCESSING(SSfastprocess, src)

///////////////////
//Suit Sensor App//
///////////////////

///A program that tracks crew members via suit sensors
/datum/computer_file/program/radar/lifeline
	filename = "lifeline"
	filedesc = "Lifeline"
	extended_desc = "This program allows for tracking of crew members via their suit sensors."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_MEDICAL)
	available_on_ntnet = TRUE
	program_icon = "heartbeat"

/datum/computer_file/program/radar/lifeline/find_atom()
	return locate(selected) in GLOB.suit_sensors_list

/datum/computer_file/program/radar/lifeline/scan()
	if(!COOLDOWN_FINISHED(src, last_scan))
		return
	COOLDOWN_START(src, last_scan, SCAN_COOLDOWN)
	objects = list()
	var/count = 0
	for(var/mob/living/L in GLOB.suit_sensors_list) // if you need to find other ones, use differnet GLOB like GLOB.carbon_list
		if(!trackable(L))
			continue
		var/crewmember_name = "Unknown"
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.wear_id)
				var/obj/item/card/id/I = H.wear_id.GetID()
				if(I?.registered_name)
					crewmember_name = I.registered_name
		else
			crewmember_name = L.name // non-human can't get ID card, but displaying them as Unknown is annoying
		var/list/crewinfo = list(
			ref = REF(L),
			name = "[++count]. [crewmember_name]",
			)
		objects += list(crewinfo)

/datum/computer_file/program/radar/lifeline/trackable(mob/target_mob)
	return checks_trackable_lifeline(computer, target_mob, tracks_grand_z, JAMMER_PROTECTION_SENSOR_NETWORK)

///Tracks all janitor equipment
/datum/computer_file/program/radar/custodial_locator
	filename = "custodiallocator"
	filedesc = "Custodial Locator"
	extended_desc = "This program allows for tracking of custodial equipment."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_JANITOR)
	available_on_ntnet = TRUE
	program_icon = "broom"
	size = 2

/datum/computer_file/program/radar/custodial_locator/find_atom()
	return locate(selected) in GLOB.janitor_devices

/datum/computer_file/program/radar/custodial_locator/scan()
	if(world.time < next_scan)
		return
	next_scan = world.time + (2 SECONDS)
	objects = list()
	var/count = 0
	for(var/obj/custodial_tools as anything in GLOB.janitor_devices)
		if(!trackable(custodial_tools))
			continue
		var/tool_name = custodial_tools.name

		if(istype(custodial_tools, /obj/item/mop))
			var/obj/item/mop/wet_mop = custodial_tools
			tool_name = "[wet_mop.reagents.total_volume ? "Wet" : "Dry"] [wet_mop.name]"

		if(istype(custodial_tools, /obj/structure/janitorialcart))
			var/obj/structure/janitorialcart/janicart = custodial_tools
			tool_name = "[janicart.name] - Water level: [janicart.reagents.total_volume] / [janicart.reagents.maximum_volume]"

		if(istype(custodial_tools, /mob/living/simple_animal/bot/cleanbot))
			var/mob/living/simple_animal/bot/cleanbot/cleanbots = custodial_tools
			tool_name = "[cleanbots.name] - [cleanbots.on ? "Online" : "Offline"]"

		var/list/tool_information = list(
			ref = REF(custodial_tools),
			name = "[++count]. [tool_name]",
		)
		objects += list(tool_information)

////////////////////////
//Nuke Disk Finder App//
////////////////////////

///A program that tracks nukes and nuclear accessories
/datum/computer_file/program/radar/fission360
	filename = "fission360"
	filedesc = "Fission360"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "radarsyndicate"
	extended_desc = "This program allows for tracking of nuclear authorization disks and warheads."
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosRadarSyndicate"
	program_icon = "bomb"
	arrowstyle = "ntosradarpointerS.png"
	pointercolor = "red"
	tracks_grand_z = TRUE

/datum/computer_file/program/radar/fission360/find_atom()
	return locate(selected) in GLOB.poi_list

/datum/computer_file/program/radar/fission360/scan()
	if(!COOLDOWN_FINISHED(src, last_scan))
		return
	COOLDOWN_START(src, last_scan, SCAN_COOLDOWN)
	objects = list()
	for(var/i in GLOB.nuke_list)
		var/obj/machinery/nuclearbomb/nuke = i

		var/list/nukeinfo = list(
			ref = REF(nuke),
			name = nuke.name,
			)
		objects += list(nukeinfo)
	var/obj/item/disk/nuclear/disk = locate() in GLOB.poi_list
	var/list/nukeinfo = list(
		ref = REF(disk),
		name = "Nuke Auth. Disk",
		)
	objects += list(nukeinfo)
