
//
// Gravity Generator
//

GLOBAL_LIST_EMPTY(gravity_generators) // We will keep track of this by adding new gravity generators to the list, and keying it with the z level.

#define POWER_IDLE 0
#define POWER_UP 1
#define POWER_DOWN 2

#define GRAV_NEEDS_SCREWDRIVER 0
#define GRAV_NEEDS_WELDING 1
#define GRAV_NEEDS_PLASTEEL 2
#define GRAV_NEEDS_WRENCH 3

//
// Abstract Generator
//

/obj/machinery/gravity_generator
	name = "gravitational generator"
	desc = "A device which produces a graviton field when set up."
	icon = 'icons/obj/machines/gravity_generator.dmi'
	density = TRUE
	move_resist = INFINITY
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/sprite_number = 0

/obj/machinery/gravity_generator/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG)
	return FALSE

/obj/machinery/gravity_generator/ex_act(severity, target)
	if(severity == EXPLODE_DEVASTATE) // Very sturdy.
		set_broken()

/obj/machinery/gravity_generator/blob_act(obj/structure/blob/B)
	if(prob(20))
		set_broken()

/obj/machinery/gravity_generator/zap_act(power, zap_flags)
	. = ..()
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE)
		qdel(src)//like the singulo, tesla deletes it. stops it from exploding over and over

/obj/machinery/gravity_generator/update_icon_state()
	icon_state = "[get_status()]_[sprite_number]"
	return ..()

/obj/machinery/gravity_generator/proc/get_status()
	return "off"

// You aren't allowed to move.
/obj/machinery/gravity_generator/Move()
	. = ..()
	qdel(src)

/obj/machinery/gravity_generator/proc/set_broken()
	atom_break()

/obj/machinery/gravity_generator/proc/set_fix()
	set_machine_stat(machine_stat & ~BROKEN)

//
// Part generator which is mostly there for looks
//

/obj/machinery/gravity_generator/part
	var/obj/machinery/gravity_generator/main/main_part = null

/obj/machinery/gravity_generator/part/Destroy()
	atom_break()
	if(main_part)
		main_part.generator_parts -= src
		UnregisterSignal(main_part, COMSIG_ATOM_UPDATED_ICON)
		main_part = null
	return ..()

/obj/machinery/gravity_generator/part/attackby(obj/item/attacking_item, mob/user, params)
	return main_part?.attackby(attacking_item, user)

/obj/machinery/gravity_generator/part/get_status()
	return main_part?.get_status()

/obj/machinery/gravity_generator/part/attack_hand(mob/user, modifiers)
	return main_part?.attack_hand(user, modifiers)

/obj/machinery/gravity_generator/part/set_broken()
	..()
	if(!main_part || (main_part.machine_stat & BROKEN))
		return
	main_part.set_broken()

/// Used to eat args
/obj/machinery/gravity_generator/part/proc/on_update_icon(obj/machinery/gravity_generator/source, updates, updated)
	SIGNAL_HANDLER
	return update_appearance(updates)

//
// Main Generator with the main code
//

/obj/machinery/gravity_generator/main
	icon_state = "on_8"
	idle_power_usage = 5 KILOWATT
	active_power_usage = 50 KILOWATT
	power_channel = AREA_USAGE_ENVIRON
	sprite_number = 8
	use_power = IDLE_POWER_USE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE

	/// List of all gravity generator parts
	var/list/generator_parts = list()
	/// The gravity generator part in the very center, the fifth one, where we place the overlays.
	var/obj/machinery/gravity_generator/part/center_part

	/// Whether the gravity generator is currently active.
	var/on = TRUE
	/// If the main breaker is on/off, to enable/disable gravity.
	var/breaker = TRUE
	/// If the generatir os idle, charging, or down.
	var/charging_state = POWER_IDLE
	/// How much charge the gravity generator has, goes down when breaker is shut, and shuts down at 0.
	var/charge_count = 100

	/// The gravity overlay currently used.
	var/current_overlay = null
	/// When broken, what stage it is at (GRAV_NEEDS_SCREWDRIVER:0) (GRAV_NEEDS_WELDING:1) (GRAV_NEEDS_PLASTEEL:2) (GRAV_NEEDS_WRENCH:3)
	var/broken_state = GRAV_NEEDS_SCREWDRIVER
	/// Gravity value when on, honestly I don't know why it does it like this, but it does.
	var/setting = 1

	/// The gravity field created by the generator.
	var/datum/proximity_monitor/advanced/gravity/gravity_field
	/// Audio for when the gravgen is on
	var/datum/looping_sound/gravgen/soundloop

/obj/machinery/gravity_generator/main/admin
	use_power = NO_POWER_USE

///Station generator that spawns with gravity turned off.
/obj/machinery/gravity_generator/main/off
	on = FALSE
	breaker = FALSE
	charge_count = 0

/obj/machinery/gravity_generator/main/Initialize(mapload)
	. = ..()
	soundloop = new(src, start_immediately = FALSE)
	setup_parts()
	if(on)
		enable()
		center_part.add_overlay("activated")

	for(var/mob/living/living_creature as anything in GLOB.mob_living_list)
		living_creature.refresh_gravity()

/obj/machinery/gravity_generator/main/Destroy() // If we somehow get deleted, remove all of our other parts.
	investigate_log("was destroyed!", INVESTIGATE_GRAVITY)
	disable()
	QDEL_NULL(soundloop)
	QDEL_NULL(center_part)
	QDEL_LIST(generator_parts)
	return ..()

/obj/machinery/gravity_generator/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = CORNER_BLOCK_OFFSET(our_turf, 3, 3, -1, 0)
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/machinery/gravity_generator/part/part = new(T)
		if(count == 5) // Middle
			center_part = part
		if(count <= 3) // Their sprite is the top part of the generator
			part.set_density(FALSE)
			part.layer = WALL_OBJ_LAYER
		part.sprite_number = count
		part.main_part = src
		generator_parts += part
		part.update_appearance(UPDATE_ICON_STATE)
		part.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, TYPE_PROC_REF(/obj/machinery/gravity_generator/part, on_update_icon))

/obj/machinery/gravity_generator/main/set_broken()
	. = ..()
	for(var/obj/machinery/gravity_generator/internal_parts as anything in generator_parts)
		if(!(internal_parts.machine_stat & BROKEN))
			internal_parts.set_broken()
	center_part.cut_overlays()
	charge_count = 0
	breaker = FALSE
	set_power()
	disable()
	investigate_log("has broken down.", INVESTIGATE_GRAVITY)

/obj/machinery/gravity_generator/main/set_fix()
	. = ..()
	for(var/obj/machinery/gravity_generator/internal_parts as anything in generator_parts)
		if(internal_parts.machine_stat & BROKEN)
			internal_parts.set_fix()
	broken_state = FALSE
	update_appearance(UPDATE_ICON_STATE)
	set_power()

// Interaction

/obj/machinery/gravity_generator/main/examine(mob/user)
	. = ..()
	if(!(machine_stat & BROKEN))
		return
	switch(broken_state)
		if(GRAV_NEEDS_SCREWDRIVER)
			. += span_notice("The entire frame is barely holding together, the <b>screws</b> need to be refastened.")
		if(GRAV_NEEDS_WELDING)
			. += span_notice("There's lots of broken seals on the framework, it could use some <b>welding</b>.")
		if(GRAV_NEEDS_PLASTEEL)
			. += span_notice("Some of this damaged plating needs full replacement. <b>10 plasteel</> should be enough.")
		if(GRAV_NEEDS_WRENCH)
			. += span_notice("The new plating just needs to be <b>bolted</b> into place now.")

// Fixing the gravity generator.
/obj/machinery/gravity_generator/main/attackby(obj/item/attacking_item, mob/user, params)
	switch(broken_state)
		if(GRAV_NEEDS_SCREWDRIVER)
			if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("You secure the screws of the framework."))
				attacking_item.play_tool_sound(src)
				broken_state++
				update_appearance(UPDATE_ICON_STATE)
				return
		if(GRAV_NEEDS_WELDING)
			if(attacking_item.tool_behaviour == TOOL_WELDER)
				if(attacking_item.use_tool(src, user, 0, volume = 50, amount = 1))
					to_chat(user, span_notice("You mend the damaged framework."))
					broken_state++
					update_appearance(UPDATE_ICON_STATE)
				return
		if(GRAV_NEEDS_PLASTEEL)
			if(istype(attacking_item, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/plasteel = attacking_item
				if(plasteel.get_amount() >= 10)
					plasteel.use(10)
					to_chat(user, span_notice("You add the plating to the framework."))
					playsound(src, 'sound/machines/click.ogg', 75, TRUE)
					broken_state++
					update_appearance(UPDATE_ICON_STATE)
				else
					to_chat(user, span_warning("You need 10 sheets of plasteel!"))
				return
		if(GRAV_NEEDS_WRENCH)
			if(attacking_item.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You secure the plating to the framework."))
				attacking_item.play_tool_sound(src)
				set_fix()
				return
	return ..()


/obj/machinery/gravity_generator/main/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(charging_state != POWER_IDLE && !(machine_stat & BROKEN))
		. = TRUE // Autoupdate while charging up/down

/obj/machinery/gravity_generator/main/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GravityGenerator")
		ui.open()

/obj/machinery/gravity_generator/main/ui_data(mob/user)
	var/list/data = list()

	data["breaker"] = breaker
	data["charge_count"] = charge_count
	data["charging_state"] = charging_state
	data["on"] = on
	data["operational"] = (machine_stat & BROKEN) ? FALSE : TRUE

	return data

/obj/machinery/gravity_generator/main/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("gentoggle")
			breaker = !breaker
			investigate_log("was toggled [breaker ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"] by [key_name(usr)].", INVESTIGATE_GRAVITY)
			set_power()
			. = TRUE

// Power and Icon States

/obj/machinery/gravity_generator/main/power_change()
	. = ..()
	investigate_log("has [machine_stat & NOPOWER ? "lost" : "regained"] power.", INVESTIGATE_GRAVITY)
	set_power()

/obj/machinery/gravity_generator/main/get_status()
	if(machine_stat & BROKEN)
		return "fix[min(broken_state, 3)]"
	return on || charging_state != POWER_IDLE ? "on" : "off"

// Set the charging state based on power/breaker.
/obj/machinery/gravity_generator/main/proc/set_power()
	var/new_state = FALSE
	if(breaker && !(machine_stat & (NOPOWER|BROKEN)))
		new_state = TRUE

	charging_state = new_state ? POWER_UP : POWER_DOWN // Startup sequence animation.
	investigate_log("is now [charging_state == POWER_UP ? "charging" : "discharging"].", INVESTIGATE_GRAVITY)
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/gravity_generator/main/proc/enable()
	charging_state = POWER_IDLE
	on = TRUE
	update_use_power(ACTIVE_POWER_USE)

	soundloop.start()
	var/old_gravity = gravity_in_level()
	complete_state_update()
	if (isnull(gravity_field))	// because if it isn't null, we have just overwritten it
		gravity_field = new(src, 2, TRUE, 6)

	if (!old_gravity)
		if(SSticker.current_state == GAME_STATE_PLAYING)
			investigate_log("was brought online and is now producing gravity for this level.", INVESTIGATE_GRAVITY)
			message_admins("The gravity generator was brought online [ADMIN_VERBOSEJMP(src)]")
		shake_everyone()

/obj/machinery/gravity_generator/main/proc/disable()
	charging_state = POWER_IDLE
	on = FALSE
	update_use_power(IDLE_POWER_USE)

	soundloop.stop()
	QDEL_NULL(gravity_field)
	var/old_gravity = gravity_in_level()
	complete_state_update()

	if (old_gravity)
		if(SSticker.current_state == GAME_STATE_PLAYING)
			investigate_log("was brought offline and there is now no gravity for this level.", INVESTIGATE_GRAVITY)
			message_admins("The gravity generator was brought offline with no backup generator. [ADMIN_VERBOSEJMP(src)]")
		shake_everyone()

/obj/machinery/gravity_generator/main/proc/complete_state_update()
	update_appearance(UPDATE_ICON_STATE)
	update_list()
	ui_update()

// Charge/Discharge and turn on/off gravity when you reach 0/100 percent.
/obj/machinery/gravity_generator/main/process()
	if(machine_stat & BROKEN)
		return
	if(charging_state == POWER_IDLE)
		return
	if(charging_state == POWER_UP && charge_count >= 100)
		enable()
	else if(charging_state == POWER_DOWN && charge_count <= 0)
		disable()
	else
		if(charging_state == POWER_UP)
			charge_count += 2
		else if(charging_state == POWER_DOWN)
			charge_count -= 2

		if(charge_count % 4 == 0 && prob(75)) // Let them know it is charging/discharging.
			playsound(src, 'sound/effects/empulse.ogg', 100, TRUE)

		if(prob(25)) // To help stop "Your clothes feel warm." spam.
			radiation_pulse(src, max_range = 2)

		var/overlay_state = null
		switch(charge_count)
			if(0 to 20)
				overlay_state = null
			if(21 to 40)
				overlay_state = "startup"
			if(41 to 60)
				overlay_state = "idle"
			if(61 to 80)
				overlay_state = "activating"
			if(81 to 100)
				overlay_state = "activated"

		if(overlay_state != current_overlay)
			if(center_part)
				center_part.cut_overlays()
				if(overlay_state)
					center_part.add_overlay(overlay_state)
				current_overlay = overlay_state

// Shake everyone on the z level to let them know that gravity was enagaged/disenagaged.
/obj/machinery/gravity_generator/main/proc/shake_everyone()
	var/turf/T = get_turf(src)
	var/sound/alert_sound = sound('sound/effects/alert.ogg')
	for(var/mob/mob as anything in GLOB.mob_list)
		var/turf/mob_turf = get_turf(mob)
		if(!istype(mob_turf))
			continue
		if(!is_valid_z_level(T, mob_turf))
			continue
		if(isliving(mob))
			var/mob/living/grav_update = mob
			grav_update.refresh_gravity()
		if(mob.client)
			shake_camera(mob, 15, 1)
			mob.playsound_local(T, null, 100, 1, 0.5, S = alert_sound)

/obj/machinery/gravity_generator/main/proc/gravity_in_level()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return FALSE
	if(GLOB.gravity_generators["[our_turf.get_virtual_z_level()]"])
		return length(GLOB.gravity_generators["[our_turf.get_virtual_z_level()]"])
	return FALSE

/obj/machinery/gravity_generator/main/proc/update_list()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/list/z_list = list()
	// Multi-Z, station gravity generator generates gravity on all ZTRAIT_STATION z-levels.
	if(SSmapping.level_trait(our_turf.z, ZTRAIT_STATION))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			z_list += z
	else
		z_list += our_turf.get_virtual_z_level()
	for(var/z in z_list)
		if(!GLOB.gravity_generators["[z]"])
			GLOB.gravity_generators["[z]"] = list()
		if(on)
			GLOB.gravity_generators["[z]"] |= src
		else
			GLOB.gravity_generators["[z]"] -= src
		SSmapping.calculate_z_level_gravity(z)

/obj/machinery/gravity_generator/main/beforeShuttleMove(turf/newT, rotation, move_mode, obj/docking_port/mobile/moving_dock)
	. = ..()
	disable()

/obj/machinery/gravity_generator/main/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if(charge_count != 0 && charging_state != POWER_UP)
		enable()

// Misc

/// Gravity generator instruction guide
/obj/item/paper/guides/jobs/engi/gravity_gen
	name = "paper- 'Generate your own gravity!'"
	default_raw_text = {"<h1>Gravity Generator Instructions For Dummies</h1>
	<p>Surprisingly, gravity isn't that hard to make! All you have to do is inject deadly radioactive minerals into a ball of
	energy and you have yourself gravity! You can turn the machine on or off when required.
	The generator produces a very harmful amount of gravity when enabled, so don't stay close for too long.</p>
	<br>
	<h3>It blew up!</h3>
	<p>Don't panic! The gravity generator was designed to be easily repaired. If, somehow, the sturdy framework did not survive then
	please proceed to panic; otherwise follow these steps.</p><ol>
	<li>Secure the screws of the framework with a screwdriver.</li>
	<li>Mend the damaged framework with a welding tool.</li>
	<li>Add additional plasteel plating.</li>
	<li>Secure the additional plating with a wrench.</li></ol>"}

#undef POWER_IDLE
#undef POWER_UP
#undef POWER_DOWN
#undef GRAV_NEEDS_SCREWDRIVER
#undef GRAV_NEEDS_WELDING
#undef GRAV_NEEDS_PLASTEEL
#undef GRAV_NEEDS_WRENCH
