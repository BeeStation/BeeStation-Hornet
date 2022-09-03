/datum/orbital_objective/destroy_ship
	name = "Intercept Vessel"
	min_payout = 3000
	max_payout = 12000
	weight = 2
	var/datum/registered_port
	var/datum/registered_shuttle_data

/datum/orbital_objective/destroy_ship/get_text()
	. = "An unidentified vessel has been causing problems somewhere in this sector. We require a team to \
		intercept and destroy this vessel."

/datum/orbital_objective/destroy_ship/on_assign(obj/machinery/computer/objective/objective_computer)
	//Select a ship
	var/datum/map_template/shuttle/supercruise/selected_ship = SSmapping.shuttle_templates["encounter_syndicate_prisoner_transport"]
	//Spawn the ship
	var/datum/turf_reservation/preview_reservation = SSmapping.RequestBlockReservation(selected_ship.width, selected_ship.height, SSmapping.transit.z_value, /datum/turf_reservation/transit)
	if(!preview_reservation)
		CRASH("failed to reserve an area for shuttle template loading")
	var/turf/BL = TURF_FROM_COORDS_LIST(preview_reservation.bottom_left_coords)

	//Setup the docking port
	var/obj/docking_port/mobile/M = selected_ship.place_port(BL, FALSE, TRUE, rand(-6000, 6000), rand(-6000, 6000))

	SSorbits.update_shuttle_name(M.id, "[M.name] (OBJECTIVE)")

	//Give the ship some AI
	var/datum/shuttle_data/located_shuttle = SSorbits.get_shuttle_data(M.id)
	located_shuttle.set_pilot(new /datum/shuttle_ai_pilot/npc/hostile())
	var/selected_faction = pickweight(list(
		/datum/faction/felinids = 2,
		/datum/faction/golems = 3,
		/datum/faction/independant = 10,
		/datum/faction/pirates = 15,
		/datum/faction/spider_clan = 3,
		/datum/faction/syndicate/arc = 1,
		/datum/faction/syndicate/cybersun = 1,
		/datum/faction/syndicate/donk = 1,
		/datum/faction/syndicate/gorlex = 1,
		/datum/faction/syndicate/mi_thirteen = 1,
		/datum/faction/syndicate/self = 1,
		/datum/faction/syndicate/tiger_corp = 1,
		/datum/faction/syndicate/waffle = 1,
	))
	located_shuttle.faction = new selected_faction()

	registered_port = M
	registered_shuttle_data = located_shuttle

	//On destroy, complete the objective
	RegisterSignal(M, COMSIG_PARENT_QDELETING, /datum/orbital_objective.proc/complete_objective)
	RegisterSignal(located_shuttle, COMSIG_PARENT_QDELETING, /datum/orbital_objective.proc/complete_objective)
	RegisterSignal(located_shuttle, COMSIG_SHUTTLE_NPC_INCAPACITATED, /datum/orbital_objective.proc/complete_objective)

/datum/orbital_objective/destroy_ship/complete_objective()
	UnregisterSignal(registered_port, COMSIG_PARENT_QDELETING)
	UnregisterSignal(registered_shuttle_data, COMSIG_PARENT_QDELETING)
	UnregisterSignal(registered_shuttle_data, COMSIG_SHUTTLE_NPC_INCAPACITATED)
	registered_port = null
	registered_shuttle_data = null
	. = ..()

/// You can't fail this objective
/datum/orbital_objective/destroy_ship/check_failed()
	return FALSE
