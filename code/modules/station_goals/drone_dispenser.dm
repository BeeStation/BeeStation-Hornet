//Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals ,y plants, z human dna
// DNA vaults require high tier stock parts and cold
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.

/datum/station_goal/drone_dispenser
	name = "Drone Dispenser"
	var/drones_produced

/datum/station_goal/drone_dispenser/New()
	..()
	drones_produced = rand(1,5)

/datum/station_goal/drone_dispenser/get_report()
	return {"Our long term prediction systems indicate a 99% chance of system-wide cataclysm in the near future.
	 We need you to construct a DNA Vault aboard your station.

	 The DNA Vault needs to contain samples of:
	 [animal_count] unique animal data
	 [plant_count] unique non-standard plant data
	 [human_count] unique sapient humanoid DNA data

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

