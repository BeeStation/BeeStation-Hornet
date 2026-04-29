/**
 * In the end having singularity and tesla being subtypes of a common parent type is much more convenient
 */
/obj/anomaly
	pass_flags_self = PASSANOMALY
	flags_1 = SUPERMATTER_IGNORES_1

	/// How strong are we?
	var/energy
	/// Do we lose energy over time?
	var/dissipate = TRUE
	/// How long should it take for us to dissipate in seconds?
	var/dissipate_delay = 2 SECONDS
	/// How much energy do we lose every dissipate_delay?
	var/dissipate_strength = 1
	/// How long its been (in seconds) since the last dissipation
	var/time_since_last_dissipiation = 0
	/// How long until we start to dissipate/gain energy again after beeing hit by a /obj/projectile/energy/accelerated_particle/weak
	var/conistant_energy_cooldown = 10 SECONDS

	COOLDOWN_DECLARE(dissipation_cooldown)

/obj/anomaly/proc/dissipate(delta_time)
	if(!dissipate && !COOLDOWN_FINISHED(src, dissipation_cooldown))
		return
	time_since_last_dissipiation += delta_time

	// Uses a while in case of especially long delta times
	while(time_since_last_dissipiation >= dissipate_delay)
		energy -= dissipate_strength

	time_since_last_dissipiation -= dissipate_delay

/obj/anomaly/bullet_act(obj/projectile/energy/accelerated_particle/P, def_zone, piercing_hit = FALSE)
	if(istype(P))
		if(P.stop_dissipate) //if we get hit by the weak version we won't dissipate nor gain energy
			COOLDOWN_START(src, dissipation_cooldown, conistant_energy_cooldown)
		else
			COOLDOWN_RESET(src, dissipation_cooldown) //if we get hit by another type of particle we start the normal process again immediately
			energy += P.energy
	else
		return ..() //highly doubt that anything else could hit this but just in case
