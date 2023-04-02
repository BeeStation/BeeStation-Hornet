/obj/item/grenade/gas_crystal
	desc = "Some kind of crystal, this shouldn't spawn"
	name = "Gas Crystal"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	resistance_flags = FIRE_PROOF

/obj/item/grenade/gas_crystal/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/turf_loc = get_turf(src)
	log_grenade(user, turf_loc) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, "<span class='warning'>You crush the [src]! [capitalize(DisplayTimeText(det_time))]!</span>")
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', volume, TRUE)
	addtimer(CALLBACK(src, .proc/prime), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/gas_crystal/healium_crystal
	name = "Healium crystal"
	desc = "A crystal made from the Healium gas, it's cold to the touch."
	icon_state = "healium_crystal"
	///Amount of stamina damage mobs will take if in range
	var/stamina_damage = 30
	///Range of the grenade that will cool down and affect mobs
	var/freeze_range = 4
	///Amount of gas released if the state is optimal
	var/gas_amount = 200

/obj/item/grenade/gas_crystal/healium_crystal/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/turf_loc in view(freeze_range, loc))
		if(!isopenturf(turf_loc))
			continue
		var/distance_from_center = max(get_dist(turf_loc, loc), 1)
		var/turf/open/floor_loc = turf_loc
		if(floor_loc.air.return_temperature() > 260 && floor_loc.air.return_temperature() < 370)
			floor_loc.atmos_spawn_air("n2=[(gas_amount - 150) / distance_from_center];TEMP=273")
		if(floor_loc.air.return_temperature() > 370)
			floor_loc.atmos_spawn_air("n2=[gas_amount / distance_from_center];TEMP=30")
			floor_loc.MakeSlippery(TURF_WET_PERMAFROST, (5 / distance_from_center) MINUTES)
		if(floor_loc.air.get_gases(GAS_PLASMA))
			floor_loc.air.adjust_moles(GAS_PLASMA, -(floor_loc.air.get_moles(GAS_PLASMA) * 0.5 / distance_from_center))
		for(var/mob/living/carbon/live_mob in turf_loc)
			live_mob.adjustStaminaLoss(stamina_damage / distance_from_center)
			live_mob.adjust_bodytemperature(-150 / distance_from_center)
	qdel(src)

/obj/item/grenade/gas_crystal/pluonium_crystal
	name = "Pluonium crystal"
	desc = "A crystal made from pluonium, you can see the liquid nitrogen and oxygen inside."
	icon_state = "pluonium_crystal"
	///Range of the grenade air refilling
	var/refill_range = 5
	///Amount of Nitrogen gas released (close to the grenade)
	var/n2_gas_amount = 80
	///Amount of Oxygen gas released (close to the grenade)
	var/o2_gas_amount = 30

/obj/item/grenade/gas_crystal/pluonium_crystal/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/turf_loc in view(refill_range, loc))
		if(!isopenturf(turf_loc))
			continue
		var/distance_from_center = max(get_dist(turf_loc, loc), 1)
		var/turf/open/floor_loc = turf_loc
		floor_loc.atmos_spawn_air("n2=[n2_gas_amount / distance_from_center];o2=[o2_gas_amount / distance_from_center];TEMP=273")
	qdel(src)

/obj/item/grenade/gas_crystal/nitrous_oxide_crystal
	name = "N2O crystal"
	desc = "A crystal made from the N2O gas, you can see the liquid gases inside."
	icon_state = "n2o_crystal"
	///Range of the grenade air refilling
	var/fill_range = 1
	///Amount of n2o gas released (close to the grenade)
	var/n2o_gas_amount = 10

/obj/item/grenade/gas_crystal/nitrous_oxide_crystal/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	for(var/turf/turf_loc in view(fill_range, loc))
		if(!isopenturf(turf_loc))
			continue
		var/distance_from_center = max(get_dist(turf_loc, loc), 1)
		var/turf/open/floor_loc = turf_loc
		floor_loc.atmos_spawn_air("n2o=[n2o_gas_amount / distance_from_center];TEMP=273")
	qdel(src)
