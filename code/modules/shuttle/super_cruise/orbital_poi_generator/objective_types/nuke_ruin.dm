/datum/orbital_objective/nuclear_bomb
	name = "Nuclear Decomission"
	var/generated = FALSE
	//The blackbox required to recover.
	var/obj/machinery/nuclearbomb/decomission/nuclear_bomb
	var/obj/item/disk/nuclear/decommission/nuclear_disk
	min_payout = 6000
	max_payout = 25000

/datum/orbital_objective/nuclear_bomb/generate_objective_stuff(turf/chosen_turf)
	generated = TRUE
	nuclear_disk = new(chosen_turf)
	nuclear_bomb.target_z = chosen_turf.z
	nuclear_bomb.linked_objective = src

/datum/orbital_objective/nuclear_bomb/get_text()
	. = "Outpost [station_name] requires immediate decomissioning to prevent infomation from being \
		leaked to the space press. Retrieve the nuclear authentication disk from the outpost and detonate it \
		with the provided nuclear bomb which will be delivered to the bridge."
	if(linked_beacon)
		. += " The station is located at the beacon marked [linked_beacon.name]. Good luck."

/datum/orbital_objective/nuclear_bomb/on_assign(obj/machinery/computer/objective/objective_computer)
	var/area/A = GLOB.areas_by_type[/area/bridge]
	var/turf/open/T = locate() in shuffle(A.contents)
	nuclear_bomb = new /obj/machinery/nuclearbomb/decomission(T)

/datum/orbital_objective/nuclear_bomb/check_failed()
	if((!QDELETED(nuclear_bomb) && !QDELETED(nuclear_disk) && !QDELETED(linked_beacon)) || !generated)
		return FALSE
	return TRUE

//==============
//The disk
//==============

/obj/item/disk/nuclear/decommission
	name = "outdated nuclear authentication disk"
	desc = "An old, worn nuclear authentication disk used in the outdated X-7 nuclear fission explosive. Nanotrasen no longer uses this model of authentication due to its poor security."
	fake = TRUE

/obj/item/disk/nuclear/decommission/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "AUTH0", TRUE)
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#f3d594", TRUE, TRUE)

//==============
//The bomb
//==============

GLOBAL_LIST_EMPTY(decomission_bombs)

/obj/machinery/nuclearbomb/decomission
	desc = "A nuclear bomb for destroying stations. Uses an old version of the nuclear authentication disk."
	proper_bomb = FALSE
	var/datum/orbital_objective/nuclear_bomb/linked_objective
	var/target_z

/obj/machinery/nuclearbomb/decomission/Initialize(mapload)
	. = ..()
	GLOB.decomission_bombs += src
	r_code = "[rand(10000, 99999)]"
	print_command_report("Nuclear decomission explosive code: [r_code]")
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,4)
	new /obj/effect/pod_landingzone(get_turf(src), pod)
	forceMove(pod)
	AddComponent(/datum/component/gps, "BOMB0", TRUE)
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#df3737", TRUE, TRUE)

/obj/machinery/nuclearbomb/decomission/Destroy()
	. = ..()
	GLOB.decomission_bombs -= src

/obj/machinery/nuclearbomb/decomission/process()
	if(z != target_z)
		timing = FALSE
		detonation_timer = null
		countdown?.stop()
		update_icon()
		return
	. = ..()

/obj/machinery/nuclearbomb/decomission/disk_check(obj/item/disk/nuclear/D)
	if(istype(D, /obj/item/disk/nuclear/decommission))
		return TRUE
	return FALSE

/obj/machinery/nuclearbomb/decomission/set_safety()
	safety = !safety
	if(safety)
		timing = FALSE
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/decomission/set_active()
	if(safety)
		to_chat(usr, span_danger("The safety is still on."))
		return
	timing = !timing
	if(timing)
		detonation_timer = world.time + (timer_set * 10)
		countdown.start()
		exploration_announce("Nuclear fission explosive armed. Vacate the outpost immediately.", z)
	else
		detonation_timer = null
		countdown.stop()
	update_icon()

/obj/machinery/nuclearbomb/decomission/explode()
	if(z != target_z)
		timing = FALSE
		detonation_timer = null
		countdown?.stop()
		update_icon()
		return
	. = ..()

/obj/machinery/nuclearbomb/decomission/actually_explode()
	SSticker.roundend_check_paused = FALSE
	linked_objective.complete_objective()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(KillEveryoneOnZLevel), target_z)
	QDEL_NULL(linked_objective.linked_beacon)
	qdel(src)
