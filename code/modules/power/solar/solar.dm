#define SOLAR_GEN_RATE 1500
#define SOLAR_OCCLUSION_DISTANCE 20
#define PANEL_Y_OFFSET 13
#define PANEL_EDGE_Y_OFFSET (PANEL_Y_OFFSET - 2)

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'monkestation/icons/obj/power/solar.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	integrity_failure = 0.33

	var/id
	var/obscured = FALSE
	///`[0-1]` measure of obscuration -- multipllier against power generation
	var/sunfrac = 0
	///`[0-360)` degrees, which direction are we facing?
	var/azimuth_current = 0
	var/azimuth_target = 0 //same but what way we're going to face next time we turn
	var/obj/machinery/power/solar_control/control
	///do we need to turn next tick?
	var/needs_to_turn = TRUE
	///do we need to call update_solar_exposure() next tick?
	var/needs_to_update_solar_exposure = TRUE
	var/obj/effect/overlay/panel
	var/obj/effect/overlay/panel_edge

/obj/machinery/power/solar/Initialize(mapload, obj/item/solar_assembly/obj_solar_assembly)
	. = ..()

	panel_edge = add_panel_overlay("solar_panel_edge", PANEL_EDGE_Y_OFFSET)
	panel = add_panel_overlay("solar_panel", PANEL_Y_OFFSET)

	Make(obj_solar_assembly)
	connect_to_network()
	RegisterSignal(SSsun, COMSIG_SUN_MOVED, .proc/queue_update_solar_exposure)


/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	return ..()

/obj/machinery/power/solar/proc/add_panel_overlay(icon_state, y_offset)
	var/obj/effect/overlay/overlay = new()
	overlay.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_ICON
	overlay.appearance_flags = TILE_BOUND
	overlay.icon_state = icon_state
	overlay.layer = FLY_LAYER
	overlay.plane = SPACE_LAYER
	overlay.pixel_y = y_offset
	vis_contents += overlay
	return overlay

//set the control of the panel to a given computer
/obj/machinery/power/solar/proc/set_control(obj/machinery/power/solar_control/obj_solar_control)
	unset_control()
	control = obj_solar_control
	obj_solar_control.connected_panels += src
	queue_turn(obj_solar_control.azimuth_target)

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels -= src
		control = null

/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/obj_solar_assembly)
	if(!obj_solar_assembly)
		obj_solar_assembly = new /obj/item/solar_assembly(src)
		obj_solar_assembly.glass_type = /obj/item/stack/sheet/glass
		obj_solar_assembly.anchored = TRUE
	else
		obj_solar_assembly.forceMove(src)
	if(obj_solar_assembly.glass_type == /obj/item/stack/sheet/rglass) //if the panel is in reinforced glass
		max_integrity *= 2 								 //this need to be placed here, because panels already on the map don't have an assembly linked to
		obj_integrity = max_integrity

/obj/machinery/power/solar/crowbar_act(mob/user, obj/item/I)
	playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
	user.visible_message("[user] begins to take the glass off [src].", "<span class='notice'>You begin to take the glass off [src]...</span>")
	if(I.use_tool(src, user, 50))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		user.visible_message("[user] takes the glass off [src].", "<span class='notice'>You take the glass off [src].</span>")
		deconstruct(TRUE)
	return TRUE

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, 1)
			else
				playsound(loc, 'sound/effects/glasshit.ogg', 90, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, 1)


/obj/machinery/power/solar/obj_break(damage_flag)
	if(!(machine_stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)
		machine_stat |= BROKEN
		unset_control()
		// Make sure user can see it's broken
		var/new_angle = rand(160, 200)
		visually_turn(new_angle)
		azimuth_current = new_angle

/obj/machinery/power/solar/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			var/obj/item/solar_assembly/obj_solar_assembly = locate() in src
			if(obj_solar_assembly)
				obj_solar_assembly.forceMove(loc)
				obj_solar_assembly.give_glass(machine_stat & BROKEN)
		else
			playsound(src, "shatter", 70, 1)
			new /obj/item/shard(src.loc)
			new /obj/item/shard(src.loc)
	qdel(src)

/obj/machinery/power/solar/update_overlays()
	. = ..()
	panel.icon_state = "solar_panel[(machine_stat & BROKEN) ? "-b" : null]"
	panel_edge.icon_state = "solar_panel[(machine_stat & BROKEN) ? "-b" : "_edge"]"

/obj/machinery/power/solar/proc/queue_turn(azimuth)
	needs_to_turn = TRUE
	azimuth_target = azimuth

/obj/machinery/power/solar/proc/queue_update_solar_exposure()
	SIGNAL_HANDLER

	needs_to_update_solar_exposure = TRUE //updating right away would be wasteful if we're also turning later

/**
 * Get the 2.5D transform for the panel, given an angle
 * Arguments:
 * * angle - the angle the panel is facing
 */
/obj/machinery/power/solar/proc/get_panel_transform(angle)
	// 2.5D solar panel works by using a magic combination of transforms
	var/matrix/turner = matrix()
	// Rotate towards sun
	turner.Turn(angle)
	// "Tilt" the panel in 3D towards East and West
	turner.Shear(0, -0.6 * sin(angle))
	// Make it skinny when facing north (away), fat south
	turner.Scale(1, 0.85 * (cos(angle) * -0.5 + 0.5) + 0.15)

	return turner

/obj/machinery/power/solar/proc/visually_turn_part(part, angle)
	var/mid_azimuth = (azimuth_current + angle) / 2

	// actually flip to other direction?
	if(abs(angle - azimuth_current) > 180)
		mid_azimuth = (mid_azimuth + 180) % 360

	// Split into 2 parts so it doesn't distort on large changes
	animate(part,
		transform = get_panel_transform(mid_azimuth),
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_IN
	)
	animate(
		transform = get_panel_transform(angle),
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_OUT
	)

/obj/machinery/power/solar/proc/visually_turn(angle)
	visually_turn_part(panel, angle)
	visually_turn_part(panel_edge, angle)

/obj/machinery/power/solar/proc/update_turn()
	needs_to_turn = FALSE
	if(azimuth_current != azimuth_target)
		visually_turn(azimuth_target)
		azimuth_current = azimuth_target
		occlusion_setup()
		needs_to_update_solar_exposure = TRUE

///trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion_setup()
	obscured = TRUE

	var/distance = SOLAR_OCCLUSION_DISTANCE
	var/target_x = round(sin(SSsun.azimuth), 0.01)
	var/target_y = round(cos(SSsun.azimuth), 0.01)
	var/x_hit = x
	var/y_hit = y
	var/turf/hit

	for(var/run in 1 to distance)
		x_hit += target_x
		y_hit += target_y
		hit = locate(round(x_hit, 1), round(y_hit, 1), z)
		if(hit.opacity)
			return
		if(hit.x == 1 || hit.x == world.maxx || hit.y == 1 || hit.y == world.maxy) //edge of the map
			break
	obscured = FALSE

///calculates the fraction of the sunlight that the panel receives
/obj/machinery/power/solar/proc/update_solar_exposure()
	needs_to_update_solar_exposure = FALSE
	sunfrac = 0
	if(obscured)
		return 0

	var/sun_azimuth = SSsun.azimuth
	if(azimuth_current == sun_azimuth) //just a quick optimization for the most frequent case
		. = 1
	else
		//dot product of sun and panel -- Lambert's Cosine Law
		. = cos(azimuth_current - sun_azimuth)
		. = clamp(round(., 0.01), 0, 1)
	sunfrac = .

/obj/machinery/power/solar/process()
	if(machine_stat & BROKEN)
		return
	if(control && (!powernet || control.powernet != powernet))
		unset_control()
	if(needs_to_turn)
		update_turn()
	if(needs_to_update_solar_exposure)
		update_solar_exposure()
	if(sunfrac <= 0)
		return

	var/sgen = SOLAR_GEN_RATE * sunfrac
	add_avail(sgen)
	if(control)
		control.gen += sgen

//Bit of a hack but this whole type is a hack
/obj/machinery/power/solar/fake/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	UnregisterSignal(SSsun, COMSIG_SUN_MOVED)

/obj/machinery/power/solar/fake/process()
	return PROCESS_KILL


/// MISC

/obj/item/paper/guides/jobs/engi/solars
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	info = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or plasma! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, reinforced or regular glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

#undef SOLAR_OCCLUSION_DISTANCE
#undef PANEL_Y_OFFSET
#undef PANEL_EDGE_Y_OFFSET
