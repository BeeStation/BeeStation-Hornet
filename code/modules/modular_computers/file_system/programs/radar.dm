#define SCAN_COOLDOWN (2 SECONDS)

/datum/computer_file/program/radar //generic parent that handles most of the process
	filename = "genericfinder"
	filedesc = "debug_finder"
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
	program_icon_state = "radarntos"
	requires_ntnet = TRUE
	transfer_access = null
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
	COOLDOWN_DECLARE(last_scan)

/datum/computer_file/program/radar/run_program(mob/living/user)
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
	var/list/data = get_header_data()
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
		if("scan")
			scan()

/**
  *Updates tracking information of the selected target.
  *
  *The track() proc updates the entire set of information about the location
  *of the target, including whether the Ntos window should use a pinpointer
  *crosshair over the up/down arrows, or none in favor of a rotating arrow
  *for far away targets. This information is returned in the form of a list.
  *
*/
/datum/computer_file/program/radar/proc/track()
	var/atom/movable/signal = find_atom()
	if(!trackable(signal))
		return

	var/turf/here_turf = (get_turf(computer))
	var/turf/target_turf = (get_turf(signal))
	var/userot = FALSE
	var/rot = 0
	var/pointer = "crosshairs"
	var/locx = (target_turf.x - here_turf.x) + 24
	var/locy = (here_turf.y - target_turf.y) + 24

	if(get_dist_euclidian(here_turf, target_turf) > 24)
		userot = TRUE
		rot = round(Get_Angle(here_turf, target_turf))
	else
		if(target_turf.z > here_turf.z)
			pointer="caret-up"
		else if(target_turf.z < here_turf.z)
			pointer="caret-down"

	var/list/trackinfo = list(
		"locx" = locx,
		"locy" = locy,
		"userot" = userot,
		"rot" = rot,
		"arrowstyle" = arrowstyle,
		"color" = pointercolor,
		"pointer" = pointer,
		)
	return trackinfo

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
	if(!signal || !computer)
		return FALSE
	var/turf/here = get_turf(computer)
	var/turf/there = get_turf(signal)
	if(!here || !there)
		return FALSE //I was still getting a runtime even after the above check while scanning, so fuck it
	return (there.z == here.z) || (is_station_level(here.z) && is_station_level(there.z))

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
	transfer_access = ACCESS_MEDICAL
	available_on_ntnet = TRUE

/datum/computer_file/program/radar/lifeline/find_atom()
	return locate(selected) in GLOB.carbon_list //currently we dont have a list of humanoids so this'll have to do

/datum/computer_file/program/radar/lifeline/scan()
	if(!COOLDOWN_FINISHED(src, last_scan))
		return
	COOLDOWN_START(src, last_scan, SCAN_COOLDOWN)
	objects = list()
	for(var/i in GLOB.carbon_list)
		var/mob/living/carbon/human/humanoid = i
		if(!trackable(humanoid))
			continue
		var/crewmember_name = "Unknown"
		if(humanoid.wear_id)
			var/obj/item/card/id/ID = humanoid.wear_id.GetID()
			if(ID?.registered_name)
				crewmember_name = ID.registered_name
		var/list/crewinfo = list(
			ref = REF(humanoid),
			name = crewmember_name,
			)
		objects += list(crewinfo)

/datum/computer_file/program/radar/lifeline/trackable(mob/living/carbon/human/humanoid)
	if(!humanoid || !istype(humanoid))
		return FALSE
	if(..())
		if(humanoid in SSnanites.nanite_monitored_mobs)
			if(humanoid.is_jammed())
				return FALSE
			return TRUE
		if(istype(humanoid.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/uniform = humanoid.w_uniform
			if(uniform.is_jammed())
				return FALSE
			if(uniform.has_sensor && uniform.sensor_mode >= SENSOR_COORDS) // Suit sensors must be on maximum
				return TRUE
	return FALSE

////////////////////////
//Nuke Disk Finder App//
////////////////////////

///A program that tracks nukes and nuclear accessories
/datum/computer_file/program/radar/fission360
	filename = "fission360"
	filedesc = "Fission360"
	program_icon_state = "radarsyndicate"
	extended_desc = "This program allows for tracking of nuclear authorization disks and warheads."
	requires_ntnet = FALSE
	transfer_access = null
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosRadarSyndicate"
	arrowstyle = "ntosradarpointerS.png"
	pointercolor = "red"

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
