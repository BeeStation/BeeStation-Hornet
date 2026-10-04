// Mouse subtree to hunt down delicious cheese.
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_targets = list(/obj/item/food/cheese)
	hunt_range = 1

// Mouse subtree to hunt down ... delicious cabling?
/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/mouse
	finding_behavior = /datum/ai_behavior/find_hunt_target/mouse_cable
	hunt_targets = list(/obj/structure/cable)
	hunt_range = 0 // Only look below us
	hunt_chance = 1

// When looking for a cable, we can only bite things we can reach.
/datum/ai_behavior/find_hunt_target/mouse_cable

/datum/ai_behavior/find_hunt_target/mouse_cable/valid_dinner(mob/living/source, obj/structure/cable/dinner, radius)
	. = ..()
	if(!.)
		return

	var/turf/open/floor/below_the_cable = get_turf(dinner)
	if(!istype(below_the_cable))
		return FALSE

	return below_the_cable.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE

// Our hunts have a decent cooldown.
/datum/ai_behavior/hunt_target/interact_with_target/mouse
	hunt_cooldown = 20 SECONDS

/datum/ai_planning_subtree/approach_synthesizer

/datum/ai_planning_subtree/approach_synthesizer/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	var/atom/instrument = controller.blackboard[BB_SONG_INSTRUMENT]
	if(!isnull(instrument))
		if (!isturf(instrument.loc) || !can_see(pawn, instrument))
			controller.clear_blackboard_key(BB_SONG_INSTRUMENT)
			return
		if (pawn.CanReach(instrument))
			return
		controller.queue_behavior(/datum/ai_behavior/travel_towards/adjacent, BB_SONG_INSTRUMENT)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/piano_synth, BB_SONG_INSTRUMENT, /obj/item/instrument/piano_synth)

/datum/ai_behavior/find_and_set/piano_synth // Disinclude subtypes

/datum/ai_behavior/find_and_set/piano_synth/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	for(var/obj/item/instrument/piano_synth/synth in oview(search_range, controller.pawn))
		if(synth.type == /obj/item/instrument/piano_synth)
			return synth

/datum/ai_planning_subtree/approach_hamster_wheel

/datum/ai_planning_subtree/approach_hamster_wheel/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	var/obj/machinery/power/port_gen/hamster_wheel/wheel = controller.blackboard[BB_HAMSTER_WHEEL]
	if(!isnull(wheel))
		if(QDELETED(wheel) || !isturf(wheel.loc) || !can_see(pawn, wheel) || !wheel.anchored || wheel.active || !isnull(wheel.occupant))
			controller.clear_blackboard_key(BB_HAMSTER_WHEEL)
			return
		if (pawn.CanReach(wheel))
			return
		controller.queue_behavior(/datum/ai_behavior/travel_towards/adjacent, BB_HAMSTER_WHEEL)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set/hamster_wheel, BB_HAMSTER_WHEEL, /obj/machinery/power/port_gen/hamster_wheel)

/datum/ai_behavior/find_and_set/hamster_wheel

/datum/ai_behavior/find_and_set/hamster_wheel/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	for(var/obj/machinery/power/port_gen/hamster_wheel/wheel in oview(search_range, controller.pawn))
		if(wheel.type == /obj/machinery/power/port_gen/hamster_wheel && wheel.anchored == TRUE && wheel.active == FALSE)
			//Only use the wheel if it is available for running in
			return wheel


/datum/ai_planning_subtree/run_hamster_wheel/

/datum/ai_planning_subtree/run_hamster_wheel/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if (controller.blackboard_key_exists(BB_HAMSTER_WHEEL))
		var/obj/machinery/power/port_gen/hamster_wheel/wheel = controller.blackboard[BB_HAMSTER_WHEEL]
		wheel.add_runner(controller.pawn)
		return SUBTREE_RETURN_FINISH_PLANNING // Don't plan anything else if we're playing an instrument
