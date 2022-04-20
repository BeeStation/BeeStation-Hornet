/obj/machinery/power/shuttle_shield_generator
	name = "shield generator"
	desc = "A localised gravitational-based shield generator that provides shuttles with protection from deep space hazards."

	var/shield_health = 0
	var/max_shield_health = 100

	//50kW per health
	var/current_power_stored = 0
	var/power_per_health = 50

	//Can gain 2 shield health per second
	var/charge_rate = 100
