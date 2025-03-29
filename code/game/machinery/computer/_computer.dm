/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer-0"
	base_icon_state = "computer"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIRECTIONAL | SMOOTH_BITMASK_SKIP_CORNERS | SMOOTH_OBJ //SMOOTH_OBJ is needed because of narsie_act using initial() to restore
	smoothing_groups = list(SMOOTH_GROUP_COMPUTERS)
	canSmoothWith = list(SMOOTH_GROUP_COMPUTERS)
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	max_integrity = 200
	integrity_failure = 0.5
	armor_type = /datum/armor/machinery_computer
	clicksound = "keyboard"
	light_system = STATIC_LIGHT
	light_range = 1
	light_power = 0.5
	light_on = TRUE
	zmm_flags = ZMM_MANGLE_PLANES
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/clockwork = FALSE
	var/time_to_screwdrive = 20
	var/authenticated = FALSE

	///Should the [icon_state]_broken overlay be shown as an emissive or regular overlay?
	var/broken_overlay_emissive = FALSE

/datum/armor/machinery_computer
	fire = 40
	acid = 20

/obj/machinery/computer/Initialize(mapload)
	. = ..()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	power_change()

/obj/machinery/computer/MouseDrop_T(atom/dropping, mob/user, params)
	. = ..()

	//Adds the component only once. We do it here & not in Initialize() because there are tons of windows & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/machinery/computer/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/machinery/computer/process()
	if(machine_stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/ratvar_act()
	if(!clockwork)
		clockwork = TRUE
		icon_screen = "ratvar[rand(1, 3)]"
		icon_keyboard = "ratvar_key[rand(1, 2)]"
		icon_state = "ratvarcomputer"
		broken_overlay_emissive = TRUE
		smoothing_groups = null
		QUEUE_SMOOTH_NEIGHBORS(src)
		smoothing_flags = NONE
		update_appearance()

/obj/machinery/computer/narsie_act()
	if(clockwork && clockwork != initial(clockwork)) //if it's clockwork but isn't normally clockwork
		clockwork = FALSE
		icon_screen = initial(icon_screen)
		icon_keyboard = initial(icon_keyboard)
		broken_overlay_emissive = initial(broken_overlay_emissive)
		smoothing_flags = initial(smoothing_flags)
		smoothing_groups = list(SMOOTH_GROUP_COMPUTERS)
		canSmoothWith = list(SMOOTH_GROUP_COMPUTERS)
		SET_BITFLAG_LIST(smoothing_groups)
		SET_BITFLAG_LIST(canSmoothWith)
		QUEUE_SMOOTH(src)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)
		update_appearance()

/obj/machinery/computer/update_overlays()
	. = ..()
	if(icon_keyboard)
		if(machine_stat & NOPOWER)
			. += "[icon_keyboard]_off"
		else
			. += icon_keyboard

	// This whole block lets screens ignore lighting and be visible even in the darkest room
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return // If we don't do this broken computers glow in the dark.

	if(machine_stat & NOPOWER) // Your screen can't be on if you've got no damn charge
		return

	. += mutable_appearance(icon, icon_screen)
	. += emissive_appearance(icon, icon_screen, layer)
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/machinery/computer/power_change()
	. = ..()
	if(!.)
		return // reduce unneeded light changes
	if(machine_stat & NOPOWER)
		set_light(FALSE)
	else
		set_light(TRUE)

/obj/machinery/computer/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(circuit && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, span_notice("You start to disconnect the monitor..."))
		if(I.use_tool(src, user, time_to_screwdrive, volume=50))
			deconstruct(TRUE, user)
	return TRUE

/obj/machinery/computer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/machinery/computer/atom_break(damage_flag)
	if(!circuit) //no circuit, no breaking
		return
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		set_light(0)

/obj/machinery/computer/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		switch(severity)
			if(1)
				if(prob(50))
					atom_break(ENERGY)
			if(2)
				if(prob(10))
					atom_break(ENERGY)

/obj/machinery/computer/deconstruct(disassembled = TRUE, mob/user)
	on_deconstruction()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(circuit) //no circuit, no computer frame
			var/obj/structure/frame/computer/A = new /obj/structure/frame/computer(src.loc)
			A.setDir(dir)
			A.circuit = circuit
			// Circuit removal code is handled in /obj/machinery/Exited()
			circuit.forceMove(A)
			A.set_anchored(TRUE)
			if(machine_stat & BROKEN)
				if(user)
					to_chat(user, span_notice("The broken glass falls out."))
				else
					playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
				new /obj/item/shard(drop_location())
				new /obj/item/shard(drop_location())
				A.state = 3
				A.icon_state = "3"
			else
				if(user)
					to_chat(user, span_notice("You disconnect the monitor."))
				A.state = 4
				A.icon_state = "4"
		for(var/obj/C in src)
			C.forceMove(loc)
	qdel(src)
