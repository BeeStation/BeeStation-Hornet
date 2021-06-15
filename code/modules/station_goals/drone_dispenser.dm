//Crew has to create drone dispenser
// Cargo can order the board
// The station needs to dispense N number of drones

/datum/station_goal/drone_dispenser
	name = "Drone Dispenser"
	var/drones_produced

/datum/station_goal/drone_dispenser/New()
	..()
	drones_produced = rand(1,5)

/datum/station_goal/drone_dispenser/get_report()
	return {"We want you to construct the requirements for a self-sustaining, autonomous research facility.
	 This would require you to construct a Drone Dispenser aboard your station.

	 The Drone Dispenser needs to be operational at the end of the shift,
	 and must have dispensed at least [drones_produced] drone shells.

	 Base vault parts are available for shipping via cargo."}


/datum/station_goal/drone_dispenser/on_report()
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/drone_dispenser]
	P.special_enabled = TRUE

/datum/station_goal/drone_dispenser/check_completion()
	if(..())
		return TRUE
	var/production_count = 0
	for(var/obj/machinery/droneDispenser/M in GLOB.machines)
		production_count += M.drones_produced
	return production_count>=drones_produced

