// Workshop area for the prison wing in Brig
// load_program() calls derez(), find a way to adress that when implementing a loading/unloading method in the game

/obj/machinery/computer/holodeck/prison
	name = "workshop control console"
	desc = "a computer used to control the workshop in the prison"

	mapped_start_area = /area/holodeck/prison
	linked = /area/holodeck/prison
//check this if template fucks up
	program_type = /datum/map_template/holodeck/prison
//linked area

/obj/machinery/computer/holodeck/prison/LateInitialize()
	var/area/computer_area = get_area(src)
	if(istype(computer_area, /area/holodeck/prison))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return
	else
		. = ..()

/obj/machinery/computer/holodeck/prison/generate_program_list()
	. = ..()

/datum/map_template/holodeck/prison/update_blacklist(turf/placement, list/input_blacklist)
	. = ..()

//remove the proc that makes all items to stam damage. Find a way to have holo removed if the item isn't in the holodeck area.

//make sure the flags given at line 272 in computer.dm don't cause issues (for item)
//add emergency shutdown call on the UI for sec to shut it off

/obj/machinery/computer/holodeck/prison/process(delta_time=2) //same as parent, but don't derez items that leave the area
	if(damaged && DT_PROB(10, delta_time))
		for(var/turf/holo_turf in linked)
			if(DT_PROB(5, delta_time))
				do_sparks(2, 1, holo_turf)
				return
	. = ..()
	if(!. || program == offline_program)//we dont need to scan the holodeck if the holodeck is offline
		return

	if(!floorcheck()) //if any turfs in the floor of the holodeck are broken
		emergency_shutdown()
		damaged = TRUE
		visible_message("The holodeck overloads!")
		for(var/turf/holo_turf in linked)
			if(DT_PROB(30, delta_time))
				do_sparks(2, 1, holo_turf)
			SSexplosions.lowturf += holo_turf
			holo_turf.hotspot_expose(1000,500,1)

	for(var/obj/effect/holodeck_effect/holo_effect as anything in effects)
		holo_effect.tick()
	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/prison/power_change()
	. = ..()

/obj/machinery/computer/holodeck/prison/emp_act(severity)
	. = ..()

/obj/machinery/computer/holodeck/prison/ex_act(severity, target)
	. = ..()

/obj/machinery/computer/holodeck/prison/Destroy()
	. = ..()

/obj/machinery/computer/holodeck/prison/blob_act(obj/structure/blob/B)
	. = ..()

/obj/machinery/computer/holodeck/prison/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

/obj/machinery/computer/holodeck/prison/ui_data(mob/user)
	. = ..()

/obj/machinery/computer/holodeck/prison/ui_act(action, params)
	. = ..()

/obj/machinery/computer/holodeck/prison/nerf(nerf_this, is_loading) //We want items to behave as normal and to do damage
	return

/obj/machinery/computer/holodeck/prison/derez(atom/movable/holo_atom, silent = TRUE, forced = FALSE)
	for(var/item in spawned)
		if(!(get_turf(item) in linked)) //don't derez the items that have been hidden by prisoners
			holo_atom -= item
	. = ..()

