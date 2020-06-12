GLOBAL_LIST_INIT(bluespace_drives, list())

/obj/machinery/bluespace_drive
	name = "bluespace drive"
	var/cooldown_world_time
	var/shuttle_id = "exploration"

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	GLOB.bluespace_drives += src

/obj/machinery/bluespace_drive/examine(mob/user)
	. = ..()
	SSbluespace_exploration.spawn_and_register_shuttle(SSbluespace_exploration.spawnable_ships["Syndicate Fighter"])

/obj/machinery/bluespace_drive/proc/engage()
	if(world.time < cooldown_world_time)
		return
	//Find what shuttle we are on
	SSbluespace_exploration.shuttle_translation(shuttle_id)
