GLOBAL_LIST_INIT(bluespace_drives, list())
GLOBAL_VAR(main_bluespace_drive)


/obj/machinery/bluespace_drive
	name = "bluespace drive"
	var/cooldown_world_time
	var/shuttle_id = "exploration"
	var/drive_type = BLUESPACE_DRIVE_BSLEVEL

/obj/machinery/bluespace_drive/regular
	drive_type = BLUESPACE_DRIVE_SPACELEVEL

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	GLOB.bluespace_drives += src
	if(istype(get_area(src), /area/shuttle/exploration))
		GLOB.main_bluespace_drive = src

/obj/machinery/bluespace_drive/proc/engage(datum/star_system/target)
	if(world.time < cooldown_world_time)
		say("Bluespace Drive is currently recharging.")
		return
	if(target.visited)
		say("Bluespace instability detected. Cannot return to selected sector.")
		return
	//Find what shuttle we are on
	say("Initiating bluespace translation protocols...")
	SSbluespace_exploration.request_ship_transit_to(shuttle_id, target)
