//Stores several modifiers in a way that isn't cleared by changing species
/datum/physiology
	/// Multiplier to brute damage received.
	/// IE: A brute mod of 0.9 = 10% less brute damage.
	/// Only applies to damage dealt via [apply_damage][/mob/living/proc/apply_damage] unless factored in manually.
	var/brute_mod = 1
	/// Multiplier to burn damage received
	var/burn_mod = 1
	/// Multiplier to toxin damage received
	var/tox_mod = 1
	/// Multiplier to oxygen damage received
	var/oxy_mod = 1
	/// Multiplier to stamina damage received
	var/clone_mod = 1
	/// Multiplier to stamina damage received
	var/stamina_mod = 1
	/// Multiplier to brain damage received
	var/brain_mod = 1

	/// Multiplier to damage taken from high / low pressure exposure, stacking with the brute modifier
	var/pressure_mod = 1
	/// Multiplier to damage taken from high temperature exposure, stacking with the burn modifier
	var/heat_mod = 1
	/// Multiplier to damage taken from low temperature exposure, stacking with the toxin modifier
	var/cold_mod = 1

	var/damage_resistance = 0 // %damage reduction from all sources

	var/siemens_coeff = 1 	// resistance to shocks

	// % additive stun increaser
	var/stun_add = 0
	// % multiplicitive stun multiplayer, applied after additive is applied
	var/stun_mod = 1
	// % bleeding modifier
	var/bleed_mod = 1

	// internal armor datum
	var/datum/armor/physio_armor

	//% of hunger rate taken per tick.
	var/hunger_mod = 1

/datum/physiology/New()
	physio_armor = new
