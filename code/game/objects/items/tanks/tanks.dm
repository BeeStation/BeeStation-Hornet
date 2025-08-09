#define TTV_NO_CASING_MOD 0.25
#define REACTIONS_BEFORE_EXPLOSION 3
/// How much time (in seconds) is assumed to pass while assuming air. Used to scale overpressure/overtemp damage when assuming air.
#define ASSUME_AIR_DT_FACTOR 1

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
	armor_type = /datum/armor/item_tank
	integrity_failure = 0.5
	/// The gases this tank contains.
	var/datum/gas_mixture/air_contents = null
	/// The volume of this tank.
	var/volume = TANK_STANDARD_VOLUME
	/// Whether the tank is currently leaking.
	var/leaking = FALSE
	/// The pressure of the gases this tank supplies to internals.
	var/distribute_pressure = ONE_ATMOSPHERE
	//Used by process() to track if there's a reason to process each tick
	var/excited = TRUE
	/// Mob that is currently breathing from the tank.
	var/mob/living/carbon/breathing_mob = null


/datum/armor/item_tank
	bomb = 10
	fire = 80
	acid = 30

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

/// Called by carbons after they disconnect the tank from their breathing apparatus.
/obj/item/tank/proc/after_internals_closed(mob/living/carbon/carbon_target)
	breathing_mob = null

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
	UnregisterSignal(air_contents, COMSIG_GASMIX_MERGED)
	air_contents = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user) && !isobserver(user))
		if(icon == src)
			. += span_notice("If you want any more information you'll need to get closer.")
		return

	. += span_notice("The gauge reads [round(air_contents.total_moles(), 0.01)] mol at [round(src.air_contents.return_pressure(),0.01)] kPa.")	//yogs can read mols

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

	. += span_notice("It feels [descriptive].")

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/location = get_turf(src)
		if(location)
			location.assume_air(air_contents)
		playsound(location, 'sound/effects/spray.ogg', 10, TRUE, -3)
	return ..()

/obj/item/tank/suicide_act(mob/living/user)
	var/mob/living/carbon/human/human_user = user
	user.visible_message(span_suicide("[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(human_user) && air_contents && air_contents.return_pressure() >= 1000)
		for(var/obj/item/W in human_user)
			human_user.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(human_user, TRAIT_DISFIGURED, TRAIT_GENERIC)
		human_user.add_bleeding(BLEED_CRITICAL)
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

/**
 * Removes some volume of the tanks gases as the tanks distribution pressure.
 *
 * Arguments:
 * - volume_to_return: The amount of volume to remove from the tank.
 */
/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	var/actual_distribute_pressure = clamp(tank_pressure, 0, distribute_pressure)

	// Lets do some algebra to understand why this works, yeah?
	// R_IDEAL_GAS_EQUATION is (kPa * L) / (K * mol) by the by, so the units in this equation look something like this
	// kpa * L / (R_IDEAL_GAS_EQUATION * K)
	// Or restated (kpa * L / K) * 1/R_IDEAL_GAS_EQUATION
	// (kpa * L * K * mol) / (kpa * L * K)
	// If we cancel it all out, we get moles, which is the expected unit
	// This sort of thing comes up often in atmos, keep the tool in mind for other bits of code
	var/moles_needed = actual_distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

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

	if(QDELETED(src) || !air_contents || !leaking)
		return
	var/atom/location = loc
	if(!location)
		return
	var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
	location.assume_air(leaked_gas)

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

/// Handles the tank springing a leak.
/obj/item/tank/atom_break(damage_flag)
	. = ..()
	if(leaking)
		return

	leaking = TRUE

	START_PROCESSING(SSobj, src)

	if(atom_integrity < 0) // So we don't play the alerts while we are exploding or rupturing.
		return
	visible_message(span_warning("[src] springs a leak!"))
	playsound(src, 'sound/effects/spray.ogg', 10, TRUE, -3)

/// Handles rupturing and fragmenting
/obj/item/tank/atom_destruction(damage_flag)
	if(!air_contents)
		return ..()

	var/turf/location = get_turf(src)
	if(!location)
		return ..()

	/// Handle fragmentation
	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		var/explosion_mod = 1
		if(!istype(loc, /obj/item/transfer_valve))
			log_bomber(details = "[src.fingerprintslast] was the last key to touch", bomb = src, additional_details = ", which ruptured explosively")
		else if(!istype(src.loc?.loc, /obj/machinery/syndicatebomb))
			explosion_mod = TTV_NO_CASING_MOD
		//Give the gas a chance to build up more pressure through reacting
		for(var/i in 1 to REACTIONS_BEFORE_EXPLOSION)
			air_contents.react(src)
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE

		explosion(location, round(range*0.25), round(range*0.5), round(range), round(range*1.5), cap_modifier = explosion_mod)
	return ..()

#undef TTV_NO_CASING_MOD
#undef REACTIONS_BEFORE_EXPLOSION
#undef ASSUME_AIR_DT_FACTOR
