#define LIGHT_ON_DELAY_UPPER 3 SECONDS
#define LIGHT_ON_DELAY_LOWER 1 SECONDS
// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/overlayicon = 'icons/obj/lighting_overlay.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 0.02 KILOWATT
	active_power_usage = 0.2 KILOWATT
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	always_area_sensitive = TRUE
	var/on = FALSE					// 1 if on, 0 if off
	var/on_gs = FALSE
	var/brightness = 10			// luminosity when on, also used in power calculation
	var/bulb_power = 1			// basically the alpha of the emitted light source
	var/bulb_colour = "#FFF6ED"	// default colour of the light.
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = FALSE
	var/light_type = /obj/item/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = FALSE			// true if rigged to explode

	var/obj/item/stock_parts/cell/cell
	/// If TRUE, then cell is null, but one is pretending to exist.
	/// This is to defer emergency cell creation unless necessary, as it is very expensive.
	var/has_mock_cell = TRUE
	var/start_with_cell = TRUE	// if true, this fixture generates a very weak cell at roundstart

	var/nightshift_enabled = FALSE	//Currently in night shift mode?
	var/nightshift_allowed = TRUE	//Set to FALSE to never let this light get switched to night mode.
	var/nightshift_brightness = 7
	var/nightshift_light_power = 0.75
	var/nightshift_light_color = "#FFDBB5" //qwerty's more cozy light

	var/emergency_mode = FALSE	// if true, the light is in emergency mode
	var/no_emergency = FALSE	// if true, this light cannot ever have an emergency mode
	var/bulb_emergency_brightness_mul = 0.25	// multiplier for this light's base brightness in emergency power mode
	var/bulb_emergency_colour = COLOR_VIVID_RED	// determines the colour of the light while it's in emergency mode
	var/bulb_emergency_pow_mul = 0.75	// the multiplier for determining the light's power in emergency mode
	var/bulb_emergency_pow_min = 0.5	// the minimum value for the light's power in emergency mode

	var/bulb_vacuum_colour = "#4F82FF"	// colour of the light when air alarm is set to severe
	var/bulb_vacuum_brightness = 8
	var/static/list/lighting_overlays	// dictionary for lighting overlays

	///More stress stuff.
	var/turning_on = FALSE
	///If TRUE, the light does not have an update delay, and makes no noise when it switches states
	var/smooth_transition = FALSE

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(1)
	return ..()

/obj/machinery/light/proc/store_cell(new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_QDELETING, PROC_REF(remove_cell))

/obj/machinery/light/proc/remove_cell()
	SIGNAL_HANDLER
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
		cell = null

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()

	//Setup area colours -pb
	var/area/A = get_area(src)
	if(bulb_colour == initial(bulb_colour))
		if(istype(src, /obj/machinery/light/small))
			bulb_colour = A.lighting_colour_bulb
			brightness = A.lighting_brightness_bulb
		else
			bulb_colour = A.lighting_colour_tube
			brightness = A.lighting_brightness_tube

	if(mapload || !SSticker.HasRoundStarted())
		smooth_transition = TRUE

	if(nightshift_light_color == initial(nightshift_light_color))
		nightshift_light_color = A.lighting_colour_night
		nightshift_brightness = A.lighting_brightness_night

	if(!mapload) //sync up nightshift lighting for player made lights
		var/obj/machinery/power/apc/temp_apc = A.apc
		nightshift_enabled = temp_apc?.nightshift_lights

	if(!start_with_cell || no_emergency)
		has_mock_cell = FALSE

	spawn(2)
		switch(fitting)
			if("tube")
				brightness = A.lighting_brightness_tube
				if(prob(2))
					break_light_tube(1)
			if("bulb")
				brightness = A.lighting_brightness_bulb
				if(prob(5))
					break_light_tube(1)
		if(!mapload)
			spawn(1)
				update(FALSE, FALSE, FALSE)

	AddElement(/datum/element/atmos_sensitive)

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	. = ..()
	var/area/A = get_area(src)
	if(A.apc)
		var/obj/machinery/power/apc/temp_apc = A.apc
		nightshift_enabled = temp_apc?.nightshift_lights
		if(nightshift_enabled)
			update(FALSE, TRUE, TRUE)

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
//		A.update_lights()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/update_icon_state()
	switch(status)		// set icon_states
		if(LIGHT_OK)
			var/area/A = get_area(src)
			if(emergency_mode || (A?.fire))
				icon_state = "[base_state]_emergency"
			else if (A?.vacuum)
				icon_state = "[base_state]_vacuum"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	. = ..()

/obj/machinery/light/update_overlays()
	. = ..()
	if(!on || status != LIGHT_OK)
		return

	if(on && turning_on)
		return

	var/area/local_area = get_area(src)
	if(emergency_mode || (local_area?.fire))
		. += mutable_appearance(overlayicon, "[base_state]_emergency")
		return
	if(local_area?.vacuum)
		. += mutable_appearance(overlayicon, "[base_state]_nightshift")
		return
	if(nightshift_enabled)
		. += mutable_appearance(overlayicon, "[base_state]_nightshift")
		return
	. += mutable_appearance(overlayicon, base_state)

// Area sensitivity is traditionally tied directly to power use, as an optimization
// But since we want it for fire reacting, we disregard that
/obj/machinery/light/setup_area_power_relationship()
	. = ..()
	if(!.)
		return
	var/area/our_area = get_area(src)
	RegisterSignal(our_area, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))

/obj/machinery/light/on_enter_area(datum/source, area/area_to_register)
	..()
	RegisterSignal(area_to_register, COMSIG_AREA_FIRE_CHANGED, PROC_REF(handle_fire))
	handle_fire(area_to_register, area_to_register.fire)

/obj/machinery/light/on_exit_area(datum/source, area/area_to_unregister)
	..()
	UnregisterSignal(area_to_unregister, COMSIG_AREA_FIRE_CHANGED)

/obj/machinery/light/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	//we want fire alarm lights to not be delayed or make light_on noises during fire
	smooth_transition = TRUE
	update()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE, quiet = FALSE, instant = FALSE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	if(smooth_transition)
		smooth_transition = FALSE
		quiet = TRUE
		instant = TRUE
	emergency_mode = FALSE
	if(on)
		if(instant)
			turn_on(trigger, quiet)
		else if(!turning_on)
			turning_on = TRUE
			addtimer(CALLBACK(src, PROC_REF(turn_on), trigger, quiet), rand(LIGHT_ON_DELAY_LOWER, LIGHT_ON_DELAY_UPPER))
	else if(use_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		update_use_power(IDLE_POWER_USE)
		emergency_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		update_use_power(IDLE_POWER_USE)
		set_light(0)
	update_icon()
	if(brightness != initial(brightness))	// If the brightness isn't 10 we're changing power usage based on the new brightness
		active_power_usage = initial(active_power_usage) * (brightness / 10)
	if(on != on_gs)
		on_gs = on

	broken_sparks(start_only=TRUE)

/obj/machinery/light/proc/turn_on(trigger, quiet = FALSE)
	if(QDELETED(src))
		return FALSE
	turning_on = FALSE
	if(!on)
		return FALSE
	var/BR = brightness
	var/PO = bulb_power
	var/CO = bulb_colour
	if(color)
		CO = color
	var/area/A = get_area(src)
	if (A?.fire)
		CO = bulb_emergency_colour
	else if (A?.vacuum)
		CO = bulb_vacuum_colour
		BR = bulb_vacuum_brightness
	else if (nightshift_enabled)
		BR = nightshift_brightness
		PO = nightshift_light_power
		if(!color)
			CO = nightshift_light_color
	var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
	if(!matching)
		switchcount++
		if(rigged)
			if(status == LIGHT_OK && trigger)
				plasma_ignition(4)
		else if( prob( min(60, (switchcount^2)*0.01) ) )
			if(trigger)
				burn_out()
		else
			update_use_power(ACTIVE_POWER_USE)
			set_light(BR, PO, CO)
			if(!quiet)
				playsound(src.loc, 'sound/effects/light_on.ogg', 50)
	update_icon()
	return TRUE

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && MC_RUNNING())
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, PROC_REF(broken_sparks)), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if(has_power())
		if(cell)
			if(cell.charge == cell.maxcharge)
				return PROCESS_KILL
			cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE) //Recharge emergency power automatically while not using it
	if(emergency_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(0)
		playsound(src.loc, 'sound/effects/burnout.ogg', 65)
		update_icon()

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update(FALSE)

/obj/machinery/light/get_cell()
	if (has_mock_cell)
		store_cell(new /obj/item/stock_parts/cell/emergency_light(src))
		has_mock_cell = FALSE

	return cell

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			. += "It is turned [on? "on" : "off"]."
		if(LIGHT_EMPTY)
			. += "The [fitting] has been removed."
		if(LIGHT_BURNED)
			. += "The [fitting] is burnt out."
		if(LIGHT_BROKEN)
			. += "The [fitting] has been smashed."
	if(cell || has_mock_cell)
		. += "Its backup power charge meter reads [has_mock_cell ? 100 : round((cell.charge / cell.maxcharge) * 100, 0.1)]%."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/living/user, params)

	//Light replacer code
	if(istype(W, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/LR = W
		LR.ReplaceLight(src, user)

	// attempt to insert light
	else if(istype(W, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, span_warning("There is a [fitting] already inserted!"))
		else
			add_fingerprint(user)
			var/obj/item/light/L = W
			if(istype(L, light_type))
				if(!user.temporarilyRemoveItemFromInventory(L))
					return

				add_fingerprint(user)
				if(status != LIGHT_EMPTY)
					drop_light_tube(user)
					to_chat(user, span_notice("You replace [L]."))
				else
					to_chat(user, span_notice("You insert [L]."))
				status = L.status
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
				on = has_power()
				update()

				qdel(L)

				if(on && rigged)
					plasma_ignition(4)
			else
				to_chat(user, span_warning("This type of light requires a [fitting]!"))

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(W.tool_behaviour == TOOL_SCREWDRIVER) //If it's a screwdriver open it.
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] opens [src]'s casing.", \
				span_notice("You open [src]'s casing."), span_italics("You hear a noise."))
			deconstruct()
		else
			to_chat(user, span_userdanger("You stick \the [W] into the light socket!"))
			if(has_power() && (W.flags_1 & CONDUCT_1))
				do_sparks(3, TRUE, src)
				if (prob(75))
					electrocute_mob(user, get_area(src), src, rand(0.7,1.0), TRUE)
	else
		return ..()

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/light_construct/newlight = null
		var/cur_stage = 2
		if(!disassembled)
			cur_stage = 1
		switch(fitting)
			if("tube")
				newlight = new /obj/structure/light_construct(src.loc)
				newlight.icon_state = "tube-construct-stage[cur_stage]"

			if("bulb")
				newlight = new /obj/structure/light_construct/small(src.loc)
				newlight.icon_state = "bulb-construct-stage[cur_stage]"
		newlight.setDir(src.dir)
		newlight.stage = cur_stage
		if(!disassembled)
			newlight.take_damage(newlight.max_integrity * 0.5, sound_effect=FALSE)
			if(status != LIGHT_BROKEN)
				break_light_tube()
			if(status != LIGHT_EMPTY)
				drop_light_tube()
			new /obj/item/stack/cable_coil(loc, 1, "red")
		transfer_fingerprints_to(newlight)
		var/obj/item/stock_parts/cell/real_cell = get_cell()
		if(!QDELETED(real_cell))
			newlight.store_cell(real_cell)
			real_cell.forceMove(newlight)
			remove_cell()
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/I, mob/living/user)
	..()
	if(status == LIGHT_BROKEN || status == LIGHT_EMPTY)
		if(on && (I.flags_1 & CONDUCT_1))
			if(prob(12))
				electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()




/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/A = get_area(src)
	return !A.lightswitch && A.power_light || flickering

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(pwr)
	if(no_emergency || (!cell && !has_mock_cell))
		return FALSE
	if (has_mock_cell)
		return status == LIGHT_OK
	if(pwr ? cell.charge >= pwr : cell.charge)
		return status == LIGHT_OK
	return FALSE

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(pwr = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(pwr))
		return FALSE
	var/obj/item/stock_parts/cell/real_cell = get_cell()
	if(real_cell.charge > 2 KILOWATT) // it's meant to handle 120 W, ya doofus // Lol nevermind that
		visible_message(span_warning("[src] short-circuits from too powerful of a power cell!"))
		burn_out()
		return FALSE
	real_cell.use(pwr)
	set_light(brightness * bulb_emergency_brightness_mul, max(bulb_emergency_pow_min, bulb_emergency_pow_mul * (real_cell.charge / real_cell.maxcharge)), bulb_emergency_colour)
	return TRUE


/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = 0
	if(flickering)
		return
	flickering = 1
	if(on && status == LIGHT_OK)
		for(var/i in 1 to amount)
			if(status != LIGHT_OK)
				break
			on = !on
			update(0)
			sleep(rand(5, 15))
		on = (status == LIGHT_OK)
		update(0)
	flickering = 0

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_silicon(mob/user)
	no_emergency = !no_emergency
	to_chat(user, span_notice("Emergency lights for this fixture have been [no_emergency ? "disabled" : "enabled"]."))
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_paw(mob/living/carbon/user)
	return attack_hand(user)

/obj/machinery/light/attack_hand(mob/living/carbon/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(on)
		var/prot = 0
		if(istype(user))
			if(isethereal(user))
				var/datum/species/ethereal/E = user.dna.species
				if(E.drain_time > world.time)
					return
				var/obj/item/organ/stomach/battery/stomach = user.get_organ_slot(ORGAN_SLOT_STOMACH)
				if(!istype(stomach))
					to_chat(user, span_warning("You can't receive charge!"))
					return
				if(user.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
					to_chat(user, span_warning("You are already fully charged!"))
					return

				to_chat(user, span_notice("You start channeling some power through the [fitting] into your body."))
				E.drain_time = world.time + 35
				while(do_after(user, 30, target = src))
					E.drain_time = world.time + 35
					if(!istype(stomach))
						to_chat(user, span_warning("You can't receive charge!"))
						return
					to_chat(user, span_notice("You receive some charge from the [fitting]."))
					stomach.adjust_charge(50)
					use_power(50)
					if(stomach.charge >= stomach.max_charge)
						to_chat(user, span_notice("You are now fully charged."))
						E.drain_time = 0
						return
				to_chat(user, span_warning("You fail to receive charge from the [fitting]!"))
				E.drain_time = 0
				return

			if(user.gloves)
				var/obj/item/clothing/gloves/G = user.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
			to_chat(user, span_notice("You remove the light [fitting]."))
		else if(user.has_dna() && user.dna.check_mutation(/datum/mutation/telekinesis))
			to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
		else
			to_chat(user, span_warning("You try to remove the light [fitting], but you burn your hand on it!"))

			var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
				user.update_damage_overlays()
			return				// if burned, don't remove the light
	else
		to_chat(user, span_notice("You remove the light [fitting]."))
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = brightness

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.forceMove(loc)

	if(user) //puts it in our active hand
		L.add_fingerprint(user)
		user.put_in_active_hand(L)

	status = LIGHT_EMPTY
	update()
	return L

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, span_notice("You telekinetically remove the light [fitting]."))
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/light_tube = drop_light_tube()
	return light_tube.attack_tk(user)


// break the light and make sparks if was on

/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks && Master.current_runlevel) //not completely sure disabling this during initialize is needed but then again there are broken lights after initialize
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(on)
			do_sparks(3, TRUE, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	brightness = initial(brightness)
	on = TRUE
	update()

/obj/machinery/light/zap_act(power, zap_flags)
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		// Fire can cause a lot of lag, just do a mini explosion.
		explosion(src, 0, 0, 1, adminlog = FALSE)

		for(var/mob/living/person in range(3, src))
			person.fire_stacks = max(person.fire_stacks, 3)
			person.ignite_mob()
			person.electrocute_act(0, "[src]", flags = SHOCK_TESLA)

		qdel(src)
	else
		return ..()

// called when area power state changes
/obj/machinery/light/power_change()
	SHOULD_CALL_PARENT(FALSE)
	var/area/local_area = get_area(src)
	seton(local_area.lightswitch && local_area.power_light)

// called when on fire

/obj/machinery/light/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > 673

/obj/machinery/light/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

/obj/machinery/light/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	break_light_tube()

/obj/machinery/light/floor
	name = "floor light"
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor"		// base description and icon_state
	icon_state = "floor"
	brightness = 6
	idle_power_usage = 0.014 KILOWATT
	active_power_usage = 0.14 KILOWATT // on par with the small lights
	layer = 2.5
	light_type = /obj/item/light/bulb
	fitting = "bulb"

GLOBAL_VAR_INIT(s_flickering_lights, FALSE)

/// Flickers all lights the next time we sleep, or yield to byond.
/// Concatenates all the flicking operations together.
/proc/flicker_all_lights()
	if (GLOB.s_flickering_lights)
		return
	GLOB.s_flickering_lights = TRUE
	spawn(0)
		GLOB.s_flickering_lights = FALSE
		for(var/obj/machinery/light/L in GLOB.machines)
			if(is_station_level(L.z))
				addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))

#undef LIGHT_ON_DELAY_UPPER
#undef LIGHT_ON_DELAY_LOWER
