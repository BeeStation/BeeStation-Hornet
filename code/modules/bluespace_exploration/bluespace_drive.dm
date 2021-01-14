/obj/machinery/bluespace_drive
	name = "bluespace drive"
	desc = "A powerful state-of-the-art drive which propells a ship through hyperspatial dimensions through the use of a reality altering micro-singularity."
	icon = 'icons/obj/bluespace_drive.dmi'
	icon_state = "bluespace_drive"
	var/cooldown_world_time = 0
	var/shuttle_id = "exploration"
	var/drive_type = BLUESPACE_DRIVE_BSLEVEL
	var/cooldown = 900	//Cooldown in deciseconds

/obj/machinery/bluespace_drive/regular
	drive_type = BLUESPACE_DRIVE_SPACELEVEL

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	SSbluespace_exploration.bluespace_drives += src
	if(istype(get_area(src), /area/shuttle/exploration))
		SSbluespace_exploration.main_bluespace_drive = src
	if(prob(5))
		desc += " The danger of this device is unparalleled, capable of ending the cycle. Do not apply toolbox."

/obj/machinery/bluespace_drive/Destroy()
	. = ..()
	SSbluespace_exploration.main_bluespace_drive = null

/obj/machinery/bluespace_drive/proc/engage(datum/star_system/target)
	if(world.time < cooldown_world_time)
		say("Bluespace Drive is currently recharging.")
		return FALSE
	//Find what shuttle we are on
	cooldown_world_time = world.time + cooldown
	say("Initiating bluespace translation protocols...")
	SSbluespace_exploration.request_ship_transit_to(shuttle_id, target)
	return TRUE
