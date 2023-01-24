// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube"
	desc = "A lighting fixture."
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	always_area_sensitive = TRUE
	///What overlay the light should use
	var/overlay_icon = 'icons/obj/lighting_overlay.dmi'
	///base description and icon_state
	var/base_state = "tube"
	///Is the light on?
	var/on = FALSE
	///Amount of power used
	var/static_power_used = 0
	///Luminosity when on, also used in power calculation
	var/brightness = 8
	///Basically the alpha of the emitted light source
	var/bulb_power = 1
	///Default colour of the light.
	var/bulb_colour = "#FFF6ED"
	///LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/status = LIGHT_OK
	///Should we flicker?
	var/flickering = FALSE
	///The type of light item
	var/light_type = /obj/item/light/tube
	///String of the light type, used in descriptions and in examine
	var/fitting = "tube"
	///Count of number of times switched on/off, this is used to calculate the probability the light burns out
	var/switchcount = 0
	///True if rigged to explode
	var/rigged = FALSE
	///Cell reference
	var/obj/item/stock_parts/cell/cell
	///If true, this fixture generates a very weak cell at roundstart
	var/start_with_cell = TRUE
	///Currently in night shift mode?
	var/nightshift_enabled = FALSE
	///Set to FALSE to never let this light get switched to night mode.
	var/nightshift_allowed = TRUE
	///Brightness of the nightshift light
	var/nightshift_brightness = 8
	///Alpha of the nightshift light
	var/nightshift_light_power = 0.45
	///Basecolor of the nightshift light
	var/nightshift_light_color = "#FFDBB5"
	///If true, the light is in low power mode
	var/low_power_mode = FALSE
	///If true, this light cannot ever be in low power mode
	var/no_low_power = FALSE
	///If true, overrides lights to use emergency lighting
	var/major_emergency = FALSE
	///Multiplier for this light's base brightness during a cascade
	var/bulb_major_emergency_brightness_mul = 0.75
	///Colour of the light when major emergency mode is on
	var/bulb_emergency_colour = "#ff4e4e"
	///Multiplier for this light's base brightness in low power power mode
	var/bulb_low_power_brightness_mul = 0.25
	///Determines the colour of the light while it's in low power mode
	var/bulb_low_power_colour = "#FF3232"
	///The multiplier for determining the light's power in low power mode
	var/bulb_low_power_pow_mul = 0.75
	///The minimum value for the light's power in low power mode
	var/bulb_low_power_pow_min = 0.5
	///Power usage - W per unit of luminosity
	var/power_consumption_rate = 20

/obj/machinery/light/Move()
	if(status != LIGHT_BROKEN)
		break_light_tube(TRUE)
	return ..()

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()

	//Setup area colours
	var/area/our_area = get_area(src)
	if(bulb_colour == initial(bulb_colour))
		if(istype(src, /obj/machinery/light/small))
			bulb_colour = our_area.lighting_colour_bulb
			brightness = our_area.lighting_brightness_bulb
		else
			bulb_colour = our_area.lighting_colour_tube
			brightness = our_area.lighting_brightness_tube

	if(nightshift_light_color == initial(nightshift_light_color))
		nightshift_light_color = our_area.lighting_colour_night
		nightshift_brightness = our_area.lighting_brightness_night

	if(!mapload) //sync up nightshift lighting for player made lights
		var/obj/machinery/power/apc/temp_apc = our_area.apc
		nightshift_enabled = temp_apc?.nightshift_lights

	if(start_with_cell && !no_low_power)
		cell = new/obj/item/stock_parts/cell/emergency_light(src)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/LateInitialize()
	. = ..()
	switch(fitting)
		if("tube")
			if(prob(2))
				break_light_tube(TRUE)
		if("bulb")
			if(prob(5))
				break_light_tube(TRUE)
	addtimer(CALLBACK(src, .proc/update, FALSE), 0.1 SECONDS)

/obj/machinery/light/Destroy()
	var/area/local_area = get_area(src)
	if(local_area)
		on = FALSE
	QDEL_NULL(cell)
	return ..()

/obj/machinery/light/update_icon_state()
	switch(status) // set icon_states
		if(LIGHT_OK)
			var/area/local_area = get_area(src)
			if(low_power_mode || major_emergency || (local_area?.fire))
				icon_state = "[base_state]_emergency"
			else
				icon_state = "[base_state]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
	return ..()

/obj/machinery/light/update_overlays()
	. = ..()
	if(!on || status != LIGHT_OK)
		return

	var/area/local_area = get_area(src)
	if(low_power_mode || major_emergency || (local_area?.fire))
		. += mutable_appearance(overlay_icon, "[base_state]_emergency")
		return
	if(nightshift_enabled)
		. += mutable_appearance(overlay_icon, "[base_state]_nightshift")
		return
	. += mutable_appearance(overlay_icon, base_state)

/*
// Area sensitivity is traditionally tied directly to power use, as an optimization
// But since we want it for fire reacting, we disregard that
/obj/machinery/light/setup_area_power_relationship()
	. = ..()
	if(!.)
		return
	var/area/our_area = get_area(src)
	RegisterSignal(our_area, COMSIG_AREA_FIRE_CHANGED, .proc/handle_fire)

/obj/machinery/light/on_enter_area(datum/source, area/area_to_register)
	..()
	RegisterSignal(area_to_register, COMSIG_AREA_FIRE_CHANGED, .proc/handle_fire)
	handle_fire(area_to_register, area_to_register.fire)

/obj/machinery/light/on_exit_area(datum/source, area/area_to_unregister)
	..()
	UnregisterSignal(area_to_unregister, COMSIG_AREA_FIRE_CHANGED)
*/

/obj/machinery/light/proc/handle_fire(area/source, new_fire)
	SIGNAL_HANDLER
	update()

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = TRUE)
	switch(status)
		if(LIGHT_BROKEN,LIGHT_BURNED,LIGHT_EMPTY)
			on = FALSE
	low_power_mode = FALSE
	if(on)
		var/brightness_set = brightness
		var/power_set = bulb_power
		var/color_set = bulb_colour
		if(color)
			color_set = color
		var/area/local_area = get_area(src)
		if (local_area?.fire)
			color_set = bulb_low_power_colour
		else if (nightshift_enabled)
			brightness_set = nightshift_brightness
			power_set = nightshift_light_power
			if(!color)
				color_set = nightshift_light_color
		else if (major_emergency)
			color_set = bulb_low_power_colour
			brightness_set = brightness * bulb_major_emergency_brightness_mul
		var/matching = light && brightness_set == light.light_range && power_set == light.light_power && color_set == light.light_color
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					explode()
			else if( prob( min(60, (switchcount**2)*0.01) ) )
				if(trigger)
					burn_out()
			else
				use_power = ACTIVE_POWER_USE
				set_light(
					l_range = brightness_set,
					l_power = power_set,
					l_color = color_set
					)
	else if(has_emergency_power(LIGHT_EMERGENCY_POWER_USE) && !turned_off())
		use_power = IDLE_POWER_USE
		low_power_mode = TRUE
		START_PROCESSING(SSmachines, src)
	else
		use_power = IDLE_POWER_USE
		set_light(l_range = 0)
	update_appearance()
	update_current_power_usage()
	broken_sparks(start_only=TRUE)

/obj/machinery/light/update_current_power_usage()
	if(!on && static_power_used > 0) //Light is off but still powered
		removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
		static_power_used = 0
	else if(on) //Light is on, just recalculate usage
		var/static_power_used_new = 0
		var/area/local_area = get_area(src)
		if (nightshift_enabled && !local_area?.fire)
			static_power_used_new = nightshift_brightness * nightshift_light_power * power_consumption_rate
		else
			static_power_used_new = brightness * bulb_power * power_consumption_rate
		if(static_power_used != static_power_used_new) //Consumption changed - update
			removeStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)
			static_power_used = static_power_used_new
			addStaticPower(static_power_used, AREA_USAGE_STATIC_LIGHT)

/obj/machinery/light/update_atom_colour()
	..()
	update()

/obj/machinery/light/proc/broken_sparks(start_only=FALSE)
	if(!QDELETED(src) && status == LIGHT_BROKEN && has_power() && Master.current_runlevel)
		if(!start_only)
			do_sparks(3, TRUE, src)
		var/delay = rand(BROKEN_SPARKS_MIN, BROKEN_SPARKS_MAX)
		addtimer(CALLBACK(src, .proc/broken_sparks), delay, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)

/obj/machinery/light/process()
	if (!cell)
		return PROCESS_KILL
	if(has_power())
		if (cell.charge == cell.maxcharge)
			return PROCESS_KILL
		cell.charge = min(cell.maxcharge, cell.charge + LIGHT_EMERGENCY_POWER_USE) //Recharge emergency power automatically while not using it
	if(low_power_mode && !use_emergency_power(LIGHT_EMERGENCY_POWER_USE))
		update(FALSE) //Disables emergency mode and sets the color to normal

/obj/machinery/light/proc/burn_out()
	if(status == LIGHT_OK)
		status = LIGHT_BURNED
		icon_state = "[base_state]-burned"
		on = FALSE
		set_light(l_range = 0)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/set_on(turn_on)
	on = (turn_on && status == LIGHT_OK)
	update()

/obj/machinery/light/get_cell()
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
	if(cell)
		. += "Its backup power charge meter reads [round((cell.charge / cell.maxcharge) * 100, 0.1)]%."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/tool, mob/living/user, params)

	//Light replacer code
	if(istype(tool, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/replacer = tool
		replacer.ReplaceLight(src, user)
		return

	// attempt to insert light
	if(istype(tool, /obj/item/light))
		if(status == LIGHT_OK)
			to_chat(user, "<span class='warning'>There is a [fitting] already inserted!</span>")
			return
		add_fingerprint(user)
		var/obj/item/light/light_object = tool
		if(!istype(light_object, light_type))
			to_chat(user, "<span class='warning'>This type of light requires a [fitting]!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(light_object))
			return

		add_fingerprint(user)
		if(status != LIGHT_EMPTY)
			drop_light_tube(user)
			to_chat(user, "<span class='warning'>You replace [light_object].</span>")
		else
			to_chat(user, "<span class='notice'>You insert [light_object].</span>")
		status = light_object.status
		switchcount = light_object.switchcount
		rigged = light_object.rigged
		brightness = light_object.brightness
		on = has_power()
		update()

		qdel(light_object)

		if(on && rigged)
			explode()
		return

	// attempt to stick weapon into light socket
	if(status != LIGHT_EMPTY)
		return ..()
	if(tool.tool_behaviour == TOOL_SCREWDRIVER) //If it's a screwdriver open it.
		tool.play_tool_sound(src, 75)
		user.visible_message("<span class='notice'>[user.name] opens [src]'s casing.</span>", \
			"<span class='notice'>You open [src]'s casing.</span>", "span class='hear'>You hear a noise.</span>")
		deconstruct()
		return
	to_chat(user, "<span class='userdanger'>You stick \the [tool] into the light socket!</span>")
	if(has_power() && (tool.flags_1 & CONDUCT_1))
		do_sparks(3, TRUE, src)
		if (prob(75))
			electrocute_mob(user, get_area(src), src, (rand(7,10) * 0.1), TRUE)

/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		qdel(src)
		return
	var/obj/structure/light_construct/new_light = null
	var/current_stage = 2
	if(!disassembled)
		current_stage = 1
	switch(fitting)
		if("tube")
			new_light = new /obj/structure/light_construct(loc)
			new_light.icon_state = "tube-construct-stage[current_stage]"

		if("bulb")
			new_light = new /obj/structure/light_construct/small(loc)
			new_light.icon_state = "bulb-construct-stage[current_stage]"
	new_light.setDir(dir)
	new_light.stage = current_stage
	if(!disassembled)
		new_light.take_damage(new_light.max_integrity * 0.5, sound_effect=FALSE)
		if(status != LIGHT_BROKEN)
			break_light_tube()
		if(status != LIGHT_EMPTY)
			drop_light_tube()
		new /obj/item/stack/cable_coil(loc, 1, "red")
	transfer_fingerprints_to(new_light)
	if(!QDELETED(cell))
		new_light.cell = cell
		cell.forceMove(new_light)
		cell = null
	qdel(src)

/obj/machinery/light/attacked_by(obj/item/attacking_object, mob/living/user)
	..()
	if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		return
	if(!on || !(attacking_object.flags_1 & CONDUCT_1))
		return
	if(prob(12))
		electrocute_mob(user, get_area(src), src, 0.3, TRUE)

/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/local_area = get_area(src)
	return !local_area.lightswitch && local_area.power_light || flickering

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/local_area = get_area(src)
	return local_area.lightswitch && local_area.power_light

// returns whether this light has emergency power
// can also return if it has access to a certain amount of that power
/obj/machinery/light/proc/has_emergency_power(power_usage_amount)
	if(no_low_power || !cell)
		return FALSE
	if(power_usage_amount ? cell.charge >= power_usage_amount : cell.charge)
		return status == LIGHT_OK

// attempts to use power from the installed emergency cell, returns true if it does and false if it doesn't
/obj/machinery/light/proc/use_emergency_power(power_usage_amount = LIGHT_EMERGENCY_POWER_USE)
	if(!has_emergency_power(power_usage_amount))
		return FALSE
	if(cell.charge > 300) //it's meant to handle 120 W, ya doofus
		visible_message("<span class='warning'>[src] short-circuits from too powerful of a power cell!</span>")
		burn_out()
		return FALSE
	cell.use(power_usage_amount)
	set_light(
		l_range = brightness * bulb_low_power_brightness_mul,
		l_power = max(bulb_low_power_pow_min, bulb_low_power_pow_mul * (cell.charge / cell.maxcharge)),
		l_color = bulb_low_power_colour
		)
	return TRUE


/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = FALSE
	if(flickering)
		return
	flickering = TRUE
	if(on && status == LIGHT_OK)
		for(var/i in 1 to amount)
			if(status != LIGHT_OK)
				break
			on = !on
			update(FALSE)
			sleep(rand(5, 15))
		on = (status == LIGHT_OK)
		update(FALSE)
		. = TRUE //did we actually flicker?
	flickering = FALSE

// ai attack - make lights flicker, because why not

/obj/machinery/light/attack_ai(mob/user)
	no_low_power = !no_low_power
	to_chat(user, "<span class='notice'>Emergency lights for this fixture have been [no_low_power ? "disabled" : "enabled"].</span>")
	update(FALSE)
	return

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "<span class='warning'>There is no [fitting] in this light!</span>")
		return

	// make it burn hands unless you're wearing heat insulated gloves or have the RESISTHEAT/RESISTHEATHANDS traits
	if(!on)
		to_chat(user, "span class='notice'You remove the light [fitting].</span>")
		// create a light tube/bulb item and put it in the user's hand
		drop_light_tube(user)
		return
	var/protection_amount = 0
	var/mob/living/carbon/human/electrician = user

	if(istype(user))
		if(isethereal(user))
			var/datum/species/ethereal/E = user.dna.species
			if(E.drain_time > world.time)
				return
			var/obj/item/organ/stomach/battery/stomach = user.getorganslot(ORGAN_SLOT_STOMACH)
			if(!istype(stomach))
				to_chat(user, "<span class='warning'>You can't receive charge!</span>")
				return
			if(user.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
				to_chat(user, "<span class='warning'>You are already fully charged!</span>")
				return

			to_chat(user, "<span class='notice'>You start channeling some power through the [fitting] into your body.</span>")
			E.drain_time = world.time + 35
			while(do_after(user, 30, target = src))
				E.drain_time = world.time + 35
				if(!istype(stomach))
					to_chat(user, "<span class='warning'>You can't receive charge!</span>")
					return
				to_chat(user, "<span class='notice'>You receive some charge from the [fitting].</span>")
				stomach.adjust_charge(50)
				use_power(50)
				if(stomach.charge >= stomach.max_charge)
					to_chat(user, "<span class='notice'>You are now fully charged.</span>")
					E.drain_time = 0
					return
			to_chat(user, "<span class='warning'>You fail to receive charge from the [fitting]!</span>")
			E.drain_time = 0
			return

		if(electrician.gloves)
			var/obj/item/clothing/gloves/electrician_gloves = electrician.gloves
			if(electrician_gloves.max_heat_protection_temperature)
				protection_amount = (electrician_gloves.max_heat_protection_temperature > 360)
	else
		protection_amount = 1

	if(protection_amount > 0 || HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		to_chat(user, "<span class='notice'>You remove the light [fitting].</span>")
	else if(istype(user) && user.dna.check_mutation(TK))
		to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
	else
		var/obj/item/bodypart/affecting = electrician.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		if(affecting?.receive_damage( 0, 5 )) // 5 burn damage
			electrician.update_damage_overlays()

/* LIGHTBULB REMOVER SKILLCHIP
		if(HAS_TRAIT(user, TRAIT_LIGHTBULB_REMOVER))
			to_chat(user, span_notice("You feel like you're burning, but you can push through."))
			if(!do_after(user, 5 SECONDS, target = src))
				return
			if(affecting?.receive_damage( 0, 10 )) // 10 more burn damage
				electrician.update_damage_overlays()
			to_chat(user, span_notice("You manage to remove the light [fitting], shattering it in process."))
			break_light_tube()
*/
		else
			to_chat(user, "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>")
			return
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

/obj/machinery/light/proc/set_major_emergency_light()
	major_emergency = TRUE
	update()

/obj/machinery/light/proc/unset_major_emergency_light()
	major_emergency = FALSE
	update()

/obj/machinery/light/proc/drop_light_tube(mob/user)
	var/obj/item/light/light_object = new light_type()
	light_object.status = status
	light_object.rigged = rigged
	light_object.brightness = brightness

	// light item inherits the switchcount, then zero it
	light_object.switchcount = switchcount
	switchcount = 0

	light_object.update()
	light_object.forceMove(loc)

	if(user) //puts it in our active hand
		light_object.add_fingerprint(user)
		user.put_in_active_hand(light_object)

	status = LIGHT_EMPTY
	update()
	return light_object

/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "<span class='warning'>There is no [fitting] in this light!</span>")
		return

	to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/light_tube = drop_light_tube()
	return light_tube.attack_tk(user)

// break the light and make sparks if was on
/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = FALSE)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(loc, 'sound/effects/glasshit.ogg', 75, TRUE)
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

/obj/machinery/light/tesla_act(power, tesla_flags)
	if(tesla_flags & TESLA_MACHINE_EXPLOSIVE)
		//Fire can cause a lot of lag, just do a mini explosion.
		explosion(src,0,0,1, adminlog = 0)
		for(var/mob/living/L in range(3, src))
			L.fire_stacks = max(L.fire_stacks, 3)
			L.IgniteMob()
			L.electrocute_act(0, "Tesla Light Zap", tesla_shock = TRUE, stun = TRUE)
		qdel(src)
	else
		return ..()

// called when area power state changes
/obj/machinery/light/power_change()
	SHOULD_CALL_PARENT(FALSE)
	var/area/local_area = get_area(src)
	set_on(local_area.lightswitch && local_area.power_light)


// called when on fire
/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = 0
	break_light_tube() // break it first to give a warning
	sleep(2)
	explosion(src, light_impact_range = 2, flash_range = -1)
	sleep(1)
	qdel(src)

/*
/obj/machinery/light/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	. = COMPONENT_BLOCK_LIGHT_EATER
	if(status == LIGHT_EMPTY)
		return
	var/obj/item/light/tube = drop_light_tube()
	tube?.burn()
	return
*/



/obj/machinery/light/floor
	name = "floor light"
	icon = 'icons/obj/lighting.dmi'
	base_state = "floor" // base description and icon_state
	icon_state = "floor"
	brightness = 4
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	light_type = /obj/item/light/bulb
	fitting = "bulb"
