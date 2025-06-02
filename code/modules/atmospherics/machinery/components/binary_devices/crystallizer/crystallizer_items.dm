/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystallized oxygen and hypernoblium stored in a bottle to pressure-proof your clothes or stop reactions occurring in portable atmospheric devices."
	icon = 'icons/obj/atmospherics/crystallizer_items.dmi'
	icon_state = "hypernoblium_crystal"
	var/uses = 1

/obj/item/hypernoblium_crystal/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/obj/machinery/portable_atmospherics/atmos_device = target
	var/obj/item/clothing/worn_item = target

	if(!istype(worn_item) && !istype(atmos_device))
		to_chat(user, span_warning("The crystal can only be used on clothing and portable atmospheric devices!"))
		return

	if(istype(atmos_device))
		if(atmos_device.nob_crystal_inserted)
			to_chat(user, span_warning("[atmos_device] already has a hypernoblium crystal inserted in it!"))
			return

		atmos_device.nob_crystal_inserted = TRUE
		to_chat(user, span_notice("You insert the [src] into [atmos_device]."))

	if(istype(worn_item))
		if(istype(worn_item, /obj/item/clothing/suit/space))
			to_chat(user, span_warning("The [worn_item] is already pressure-resistant!"))
			return

		if(worn_item.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && worn_item.clothing_flags & STOPSPRESSUREDAMAGE)
			to_chat(user, span_warning("[worn_item] is already pressure-resistant!"))
			return

		to_chat(user, span_notice("You see how the [worn_item] changes color, it's now pressure proof."))
		worn_item.name = "pressure-resistant [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour("#00fff7", FIXED_COLOUR_PRIORITY)
		worn_item.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		worn_item.cold_protection = worn_item.body_parts_covered
		worn_item.clothing_flags |= STOPSPRESSUREDAMAGE

	uses--
	if(uses <= 0)
		qdel(src)

/obj/item/nitrium_crystal
	desc = "A weird brown crystal, it smokes when broken"
	name = "nitrium crystal"
	icon = 'icons/obj/atmospherics/crystallizer_items.dmi'
	icon_state = "nitrium_crystal"
	var/cloud_size = 1

/obj/item/nitrium_crystal/attack_self(mob/user)
	. = ..()

	create_reagents(5)
	reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, 3)
	reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, 2)

	var/turf/location = get_turf(src)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.attach(location)
	smoke.set_up(reagents, cloud_size, location, 0)
	smoke.start()

	qdel(src)

/obj/item/stock_parts/cell/crystal
	name = "crystal power cell"
	desc = "A very high power cell made from crystallized plasma"
	icon = 'icons/obj/atmospherics/crystallizer_items.dmi'
	icon_state = "crystal_cell"
	maxcharge = 50000
	chargerate = 0
	custom_materials = null
	grind_results = null

/**
 * Grenades
 **/

/obj/item/grenade/gas_crystal
	name = "Gas Crystal"
	desc = "Some kind of crystal, this shouldn't spawn"
	icon = 'icons/obj/atmospherics/crystallizer_items.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	resistance_flags = FIRE_PROOF

/obj/item/grenade/gas_crystal/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You crush the [src]! [capitalize(DisplayTimeText(det_time))]!"))
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', volume, TRUE)
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	if(user)
		SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, user, src, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(prime)), delayoverride || det_time)

/obj/item/grenade/gas_crystal/healium_crystal
	name = "Healium crystal"
	desc = "A crystal made from the Healium gas, it's cold to the touch."
	icon_state = "healium_crystal"

	/// The range of the grenade air refilling
	var/fix_range = 7

/obj/item/grenade/gas_crystal/healium_crystal/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	var/list/turf_list = RANGE_TURFS(fix_range, src)
	var/datum/gas_mixture/base_mix = SSair.parse_gas_string(OPENTURF_DEFAULT_ATMOS)
	for(var/turf/open/turf_fix in turf_list)
		if(turf_fix.blocks_air)
			continue
		turf_fix.copy_air(base_mix.copy())
	qdel(src)

/obj/item/grenade/gas_crystal/proto_nitrate_crystal
	name = "Proto Nitrate crystal"
	desc = "A crystal made from the Proto Nitrate gas, you can see the liquid gases inside."
	icon_state = "proto_nitrate_crystal"

	/// Range of the grenade air refilling
	var/refill_range = 5
	/// Amount of Nitrogen gas released (close to the grenade)
	var/n2_gas_amount = 80
	/// Amount of Oxygen gas released (close to the grenade)
	var/o2_gas_amount = 30

/obj/item/grenade/gas_crystal/proto_nitrate_crystal/prime(mob/living/lanced_by)
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
		floor_loc.atmos_spawn_air("[GAS_N2]=[n2_gas_amount / distance_from_center];[GAS_O2]=[o2_gas_amount / distance_from_center];[TURF_TEMPERATURE(273)]")
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
		floor_loc.atmos_spawn_air("[GAS_N2O]=[n2o_gas_amount / distance_from_center];[TURF_TEMPERATURE(273)]")
	qdel(src)

/obj/item/grenade/gas_crystal/crystal_foam
	name = "crystal foam"
	desc = "A crystal with a foggy inside"
	icon_state = "crystal_foam"
	var/breach_range = 7

/obj/item/grenade/gas_crystal/crystal_foam/prime(mob/living/lanced_by)
	. = ..()

	var/datum/reagents/first_batch = new
	var/datum/reagents/second_batch = new
	var/list/datum/reagents/reactants = list()

	first_batch.add_reagent(/datum/reagent/aluminium, 75)
	second_batch.add_reagent(/datum/reagent/smart_foaming_agent, 25)
	second_batch.add_reagent(/datum/reagent/toxin/acid/fluacid, 25)
	reactants += first_batch
	reactants += second_batch

	var/turf/detonation_turf = get_turf(src)

	chem_splash(detonation_turf, breach_range, reactants)

	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	log_game("A grenade detonated at [AREACOORD(detonation_turf)]")

	update_mob()

	qdel(src)
