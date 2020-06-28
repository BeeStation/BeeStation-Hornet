GLOBAL_LIST_INIT(bluespace_drives, list())

/obj/machinery/bluespace_drive
	name = "bluespace drive"
	var/cooldown_world_time
	var/shuttle_id = "exploration"

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	GLOB.bluespace_drives += src
	if(prob(110))
		message_admins("hi")

/obj/machinery/bluespace_drive/examine(mob/user)
	. = ..()
	SSbluespace_exploration.spawn_and_register_shuttle(SSbluespace_exploration.spawnable_ships["Syndicate Fighter"])

/obj/machinery/bluespace_drive/proc/engage(datum/star_system/target)
	if(world.time < cooldown_world_time)
		say("Bluespace Drive is currently recharging.")
		return
	if(target.visited)
		say("Bluespace instability detected. Cannot return to selected sector.")
		return
	//Find what shuttle we are on
	say("Initiating bluespace translation protocols...")
	SSbluespace_exploration.shuttle_translation(shuttle_id, target)
