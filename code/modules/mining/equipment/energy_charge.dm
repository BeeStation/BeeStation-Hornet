/obj/machinery/power/energy_charge_dispensor
	name = "energy charge dispensor"
	desc = "A machine which creates unstable packets of energy and injects them into a container, producing an explosive charge that can be used for mining. Requires a large amount of power."

/obj/machinery/power/energy_charge_dispensor/attack_hand(mob/living/user)
	. = ..()
	// Attempt to create the energy charge
