#define TTV_NO_CASING_MOD 0.25
#define REACTIONS_BEFORE_EXPLOSION 3

/obj/item/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	worn_icon = 'icons/mob/clothing/back.dmi' //since these can also get thrown into suit storage slots. if something goes on the belt, set this to null.
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	custom_materials = list(/datum/material/iron = 500)
	actions_types = list(/datum/action/item_action/set_internals)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 80, ACID = 30, STAMINA = 0)
	/// The gases this tank contains. Don't modify this directly, use return_air() to get it instead
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	/// Mob that is currently breathing from the tank.
	var/mob/living/carbon/breathing_mob = null
	///Used by process() to track if there's a reason to process each tick
	var/excited = TRUE

/obj/item/tank/dropped(mob/living/user, silent)
	. = ..()
	// Close open air tank if its current user got sent to the shadowrealm.
	if (QDELETED(breathing_mob))
		breathing_mob = null
		return
	// Close open air tank if it got dropped by it's current user.
	if (loc != breathing_mob)
		breathing_mob.cutoff_internals()

/// Closes the tank if given to another mob while open.
/obj/item/tank/equipped(mob/living/user, slot, initial)
	. = ..()
	// Close open air tank if it was equipped by a mob other than the current user.
	if (breathing_mob && (user != breathing_mob))
		breathing_mob.cutoff_internals()

/// Called by carbons after they connect the tank to their breathing apparatus.
/obj/item/tank/proc/after_internals_opened(mob/living/carbon/carbon_target)
	breathing_mob = carbon_target
	carbon_target.update_internals_hud_icon(1)

/// Called by carbons after they disconnect the tank from their breathing apparatus.
/obj/item/tank/proc/after_internals_closed(mob/living/carbon/carbon_target)
	breathing_mob = null
	carbon_target.update_internals_hud_icon(0)

/// Attempts to toggle the mob's internals on or off using this tank. Returns TRUE if successful.
/obj/item/tank/proc/toggle_internals(mob/living/carbon/mob_target)
	return mob_target.toggle_internals(src)

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/Initialize(mapload)
	. = ..()

	air_contents = new(volume) //liters
	air_contents.temperature = T20C

	populate_gas()

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/Destroy()
	if(air_contents)
		QDEL_NULL(air_contents)

	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += "<span class='notice'>If you want any more information you'll need to get closer.</span>"
		return

	. += "<span class='notice'>The gauge reads [round(air_contents.total_moles(), 0.01)] mol at [round(src.air_contents.return_pressure(),0.01)] kPa.</span>"	//yogs can read mols

	var/celsius_temperature = air_contents.return_temperature()-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	. += "<span class='notice'>It feels [descriptive].</span>"

/obj/item/tank/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		var/turf/location = get_turf(src)
		if(!location)
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(air_contents)
			air_update_turf(FALSE, FALSE)
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	qdel(src)

/obj/item/tank/suicide_act(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	user.visible_message("<span class='suicide'>[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(human_user) && air_contents && air_contents.return_pressure() >= 1000)
		for(var/obj/item/W in human_user)
			human_user.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(human_user, TRAIT_DISFIGURED, TRAIT_GENERIC)
		human_user.bleed_rate = 5
		human_user.gib_animation()
		sleep(3)
		human_user.adjustBruteLoss(1000) //to make the body super-bloody
		human_user.spawn_gibs()
		human_user.spill_organs()
		human_user.spread_bodyparts()

	return BRUTELOSS

/obj/item/tank/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	return ..()

/obj/item/tank/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/tank/ui_data(mob/user)
	var/list/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(TANK_MIN_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)

	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(!istype(C))
		return data

	if(istype(C) && C.internal == src)
		data["connected"] = TRUE

	return data

/obj/item/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([TANK_MIN_RELEASE_PRESSURE]-[TANK_MAX_RELEASE_PRESSURE] kPa):", name, distribute_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)

/obj/item/tank/remove_air(amount)
	START_PROCESSING(SSobj, src)
	return air_contents.remove(amount)

/obj/item/tank/remove_air_ratio(ratio)
	return remove_air_ratio(ratio)

/obj/item/tank/return_air()
	START_PROCESSING(SSobj, src)
	return air_contents

/obj/item/tank/return_analyzable_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	START_PROCESSING(SSobj, src)
	air_contents.merge(giver)
	handle_tolerances(ASSUME_AIR_DT_FACTOR)
	return TRUE

/obj/item/tank/assume_air_moles(datum/gas_mixture/giver, moles)
	giver.transfer_to(air_contents, moles)

	check_status()
	return 1

/obj/item/tank/assume_air_ratio(datum/gas_mixture/giver, ratio)
	giver.transfer_ratio_to(air_contents, ratio)

	check_status()
	return 1

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature())

	return remove_air(moles_needed)


/obj/item/tank/process(delta_time)
	if(!air_contents)
		return

	//Allow for reactions
	excited = (excited | air_contents.react(src))
	excited = (excited | handle_tolerances(delta_time))
	excited = (excited | leaking)

	if(!excited)
		STOP_PROCESSING(SSobj, src)
	excited = FALSE

	if(QDELETED(src) || !leaking || !air_contents)
		return
	var/atom/location = loc
	if(!location)
		return
	var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
	location.assume_air(leaked_gas)
	location.air_update_turf(FALSE, FALSE)

/**
 * Handles the minimum and maximum pressure tolerances of the tank.
 *
 * Returns true if it did anything of significance, false otherwise
 * Arguments:
 * - delta_time: How long has passed between ticks.
 */
/obj/item/tank/proc/handle_tolerances(delta_time)
	if(!air_contents)
		return FALSE

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()
	if(temperature >= TANK_MELT_TEMPERATURE)
		var/temperature_damage_ratio = (temperature - TANK_MELT_TEMPERATURE) / temperature
		take_damage(max_integrity * temperature_damage_ratio * delta_time, BURN, FIRE, FALSE, NONE)
		if(QDELETED(src))
			return TRUE

	if(pressure >= TANK_LEAK_PRESSURE)
		var/pressure_damage_ratio = (pressure - TANK_LEAK_PRESSURE) / (TANK_RUPTURE_PRESSURE - TANK_LEAK_PRESSURE)
		take_damage(max_integrity * pressure_damage_ratio * delta_time, BRUTE, BOMB, FALSE, NONE)
		return TRUE
	return FALSE

/// Handles rupturing and fragmenting
/obj/item/tank/obj_destruction(damage_flag)
	if(!air_contents)
		return ..()

	/// Handle fragmentation
	var/pressure = air_contents.return_pressure()

	if(pressure > TANK_FRAGMENT_PRESSURE)
		var/explosion_mod = 1
		if(!istype(src.loc, /obj/item/transfer_valve))
			log_bomber(details = "[src.fingerprintslast] was the last key to touch", bomb = src, additional_details = ", which ruptured explosively")
		else if(!istype(src.loc?.loc, /obj/machinery/syndicatebomb))
			explosion_mod = TTV_NO_CASING_MOD
		//Give the gas a chance to build up more pressure through reacting
		for(var/i in 1 to REACTIONS_BEFORE_EXPLOSION)
			air_contents.react(src)
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)


		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5), cap_modifier = explosion_mod)
		if(istype(src.loc, /obj/item/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	return ..()

/// Handles the tank springing a leak.
/obj/item/tank/obj_break(damage_flag)
	. = ..()
	if(leaking)
		return

	leaking = TRUE
	START_PROCESSING(SSobj, src)

	if(obj_integrity < 0) // So we don't play the alerts while we are exploding or rupturing.
		return
	visible_message("<span class='warning'>[src] springs a leak!</span>")
	playsound(src, 'sound/effects/spray.ogg', 10, TRUE, -3)


#undef TTV_NO_CASING_MOD
#undef REACTIONS_BEFORE_EXPLOSION
