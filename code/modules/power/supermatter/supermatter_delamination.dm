/datum/supermatter_delamination
	///Power amount of the SM at the moment of death
	var/supermatter_power = 0
	///Amount of total gases interacting with the SM
	var/supermatter_gas_amount = 0
	///Base number of anomalies to spawn (can go up or down with a random small amount)
	var/anomalies_to_spawn = 10
	///Can we spawn anomalies after dealing with the delamination type?
	var/should_spawn_anomalies = TRUE
	///Reference to the supermatter turf
	var/turf/supermatter_turf
	///Baseline strenght of the explosion caused by the SM
	var/supermatter_explosion_power = 0
	///Amount the gasmix will affect the explosion size
	var/supermatter_gasmix_power_ratio = 0

/datum/supermatter_delamination/New(supermatter_power, supermatter_gas_amount, turf/supermatter_turf, supermatter_explosion_power, supermatter_gasmix_power_ratio, can_spawn_anomalies)
	. = ..()

	if(!supermatter_turf) //If something or someone fucks up and have a turf
		CRASH("/datum/supermatter_delamination missing turf needed to cause a delamination.")

	src.supermatter_power = supermatter_power
	src.supermatter_gas_amount = supermatter_gas_amount
	src.supermatter_turf = supermatter_turf
	src.supermatter_explosion_power = supermatter_explosion_power
	src.supermatter_gasmix_power_ratio = supermatter_gasmix_power_ratio

	setup_mob_interactions()
	setup_delamination_type()

	if(!should_spawn_anomalies || !can_spawn_anomalies)
		qdel(src)
		return

	setup_anomalies()

/datum/supermatter_delamination/proc/setup_mob_interactions()
	var/supermatter_z = 0
	if(supermatter_turf)
		supermatter_z = supermatter_turf.get_virtual_z_level()

	for(var/mob in GLOB.alive_mob_list)
		var/mob/living/L = mob
		if(istype(L) && L.get_virtual_z_level() == supermatter_z)
			if(ishuman(mob))
				//Hilariously enough, running into a closet should make you get hit the hardest.
				var/mob/living/carbon/human/H = mob
				H.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
			var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(L, src) + 1) )
			L.rad_act(rads)

	for(var/mob/M in GLOB.player_list)
		if(M.get_virtual_z_level() == supermatter_z)
			SEND_SOUND(M, 'sound/magic/charge.ogg')
			to_chat(M, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)


/datum/supermatter_delamination/proc/setup_delamination_type()
	if(supermatter_gas_amount > MOLE_PENALTY_THRESHOLD)
		call_singulo()
		return

	if(supermatter_power > POWER_PENALTY_THRESHOLD)
		call_tesla()
		return

	call_explosion()

/datum/supermatter_delamination/proc/call_singulo()
	var/obj/anomaly/singularity/created_singularity = new(supermatter_turf)
	created_singularity.energy = 800
	created_singularity.consume(src)
	should_spawn_anomalies = FALSE
	message_admins("The Supermatter Crystal has created a singularity [ADMIN_JMP(created_singularity)].")

/datum/supermatter_delamination/proc/call_tesla()
	var/obj/anomaly/energy_ball/created_energy_ball = new(supermatter_turf, 200) //Gets us about 9 balls
	call_explosion()
	should_spawn_anomalies = FALSE
	message_admins("The Supermatter Crystal has created an energy ball [ADMIN_JMP(created_energy_ball)].")

/datum/supermatter_delamination/proc/call_explosion()
	//Dear mappers, balance the sm max explosion radius to 17.5, 37, 39, 41
	explosion(epicenter = supermatter_turf,
		devastation_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) * 0.5,
		heavy_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 2,
		light_impact_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 4,
		flash_range = supermatter_explosion_power * max(supermatter_gasmix_power_ratio, 0.205) + 6,
		adminlog = TRUE,
		ignorecap = TRUE)

/datum/supermatter_delamination/proc/setup_anomalies()
	anomalies_to_spawn = max(round(0.005 * supermatter_power, 1) + rand(-2, 5), 1)
	spawn_anomalies()

/datum/supermatter_delamination/proc/spawn_anomalies()
	var/list/anomaly_areas = GLOB.generic_event_spawns
	var/currently_spawning_anomalies = round(anomalies_to_spawn * 0.5, 1)
	anomalies_to_spawn -= currently_spawning_anomalies
	for(var/i in 1 to currently_spawning_anomalies)
		var/anomaly_to_spawn = pickweight(ANOMALY_WEIGHTS)
		var/area/target_event_spawn = pick_n_take(anomaly_areas)
		if(!target_event_spawn)
			return

		spawn_anomaly(target_event_spawn.loc, anomaly_to_spawn)

	spawn_overtime()

/datum/supermatter_delamination/proc/spawn_overtime()
	var/list/anomaly_areas = GLOB.generic_event_spawns

	var/current_spawn = rand(5 SECONDS, 10 SECONDS)
	for(var/i in 1 to anomalies_to_spawn)
		var/anomaly_to_spawn = pickweight(ANOMALY_WEIGHTS)
		var/area/target_event_spawn = pick_n_take(anomaly_areas)
		if(!target_event_spawn)
			return

		var/next_spawn = rand(5 SECONDS, 10 SECONDS)
		var/extended_spawn = 0
		if(DT_PROB(1, next_spawn))
			extended_spawn = rand(5 MINUTES, 15 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(spawn_anomaly), target_event_spawn, anomaly_to_spawn), current_spawn + extended_spawn)
		current_spawn += next_spawn

/datum/supermatter_delamination/proc/spawn_anomaly(turf/location, type)
	supermatter_anomaly_gen(anomalycenter = location, type = type, anomalyrange = 1, has_weak_lifespan = FALSE)
