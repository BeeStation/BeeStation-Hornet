#define STASIS_TOGGLE_COOLDOWN 50
/obj/machinery/stasis
	name = "lifeform stasis unit"
	desc = "A not-so-comfortable looking bed with nozzles on top and bottom. Placing someone here will suspend their vital processes, putting them in stasis until removed."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "stasis"
	density = FALSE
	can_buckle = TRUE
	circuit = /obj/item/circuitboard/machine/stasis
	idle_power_usage = 50
	active_power_usage = 500
	fair_market_price = 10
	dept_req_for_free = ACCOUNT_MED_BITFLAG
	var/stasis_enabled = TRUE
	var/last_stasis_sound = FALSE
	var/stasis_can_toggle = 0
	var/mattress_state = "stasis_on"
	var/obj/effect/overlay/vis/mattress_on
	var/obj/machinery/computer/operating/op_computer

// dir check for buckle_lying state
/obj/machinery/stasis/Initialize()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed)) //This gets called later during initialization
	return ..()

/obj/machinery/stasis/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/stasis/LateInitialize()
	. = ..()
	initial_link()

/obj/machinery/stasis/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed))
	. = ..()
	if(op_computer?.sbed == src)
		op_computer.sbed = null

/obj/machinery/stasis/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to [stasis_enabled ? "turn off" : "turn on"] the machine.</span>"
	if(op_computer)
		. += "<span class='notice'>[src] is <b>linked</b> to an operating computer to the [dir2text(get_dir(src, op_computer))].</span>"
	else
		. += "<span class='notice'>[src] is <b>NOT linked</b> to an operating computer.</span>"

/obj/machinery/stasis/proc/initial_link()
	if(!QDELETED(op_computer))
		op_computer.sbed = src
		return
	for(var/direction in GLOB.alldirs)
		var/obj/machinery/computer/operating/found_computer = locate(/obj/machinery/computer/operating) in get_step(src, direction)
		if(found_computer)
			if(!found_computer.sbed)
				found_computer.link_with_table(new_sbed = src)
				break
			else if(found_computer.sbed == src)
				op_computer = found_computer
				break

/obj/machinery/stasis/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		var/sound_freq = rand(5120, 8800)
		if(_running)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)
		last_stasis_sound = _running

/obj/machinery/stasis/AltClick(mob/user)
	if(world.time >= stasis_can_toggle && user.canUseTopic(src, !issilicon(user)))
		stasis_enabled = !stasis_enabled
		stasis_can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		play_power_sound()
		update_icon()

/obj/machinery/stasis/Exited(atom/movable/gone, direction)
	if(gone == occupant)
		var/mob/living/L = gone
		if(IS_IN_STASIS(L))
			thaw_them(L)
	return ..()

/obj/machinery/stasis/proc/stasis_running()
	return stasis_enabled && is_operational

/obj/machinery/stasis/update_icon()
	. = ..()
	var/_running = stasis_running()
	var/list/overlays_to_remove = managed_vis_overlays

	if(mattress_state)
		if(!mattress_on || !managed_vis_overlays)
			mattress_on = SSvis_overlays.add_vis_overlay(src, icon, mattress_state, layer, plane, dir, alpha = 0, unique = TRUE)

		if(mattress_on.alpha ? !_running : _running) //check the inverse of _running compared to truthy alpha, to see if they differ
			var/new_alpha = _running ? 255 : 0
			var/easing_direction = _running ? EASE_OUT : EASE_IN
			animate(mattress_on, alpha = new_alpha, time = 50, easing = CUBIC_EASING|easing_direction)

		overlays_to_remove = managed_vis_overlays - mattress_on

	SSvis_overlays.remove_vis_overlay(src, overlays_to_remove)

	if(machine_stat & BROKEN)
		icon_state = "stasis_broken"
		return
	if(panel_open || machine_stat & MAINT)
		icon_state = "stasis_maintenance"
		return
	icon_state = "stasis"

/obj/machinery/stasis/obj_break(damage_flag)
	. = ..()
	play_power_sound()
	update_icon()

/obj/machinery/stasis/power_change()
	. = ..()
	play_power_sound()
	update_icon()

/obj/machinery/stasis/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	target.ExtinguishMob()
	use_power = ACTIVE_POWER_USE

/obj/machinery/stasis/proc/thaw_them(mob/living/target)
	target.remove_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	if(target == occupant)
		use_power = IDLE_POWER_USE

/obj/machinery/stasis/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	set_occupant(L)
	if(stasis_running() && check_nap_violations())
		chill_out(L)
	update_icon()

/obj/machinery/stasis/post_unbuckle_mob(mob/living/L)
	thaw_them(L)
	if(L == occupant)
		set_occupant(null)
	update_icon()

/obj/machinery/stasis/process()
	if( !( occupant && isliving(occupant) && check_nap_violations() ) )
		use_power = IDLE_POWER_USE
		return
	var/mob/living/L_occupant = occupant
	if(stasis_running())
		if(!IS_IN_STASIS(L_occupant))
			chill_out(L_occupant)
	else if(IS_IN_STASIS(L_occupant))
		thaw_them(L_occupant)

/obj/machinery/stasis/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, "stasis_maintenance", "stasis", I)
	update_icon()

/obj/machinery/stasis/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(I)

/obj/machinery/stasis/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/multitool = I
	if(!I || !istype(I))
		return ..()
	. = TOOL_ACT_TOOLTYPE_SUCCESS
	if(!panel_open)
		to_chat(user, "<span class='warning'>\The [src]'s panel must be open in order to add it to \the [multitool]'s buffer.</span>")
		return
	multitool.buffer = src
	to_chat(user, "<span class='notice'>You store the linking data of \the [src] in \the [multitool]'s buffer. Use it on an operating computer to complete linking.</span>")
	balloon_alert(user, "saved in buffer")

/obj/machinery/stasis/wrench_act(mob/living/user, obj/item/I) //We want to rotate, but we need to do it in 180 degree rotations.
	if(panel_open && has_buckled_mobs())
		to_chat(user, "<span class='notice'>\The [src] is too heavy to rotate while someone is buckled to it!</span>")
		return TRUE
	. = default_change_direction_wrench(user, I, 2)

/obj/machinery/stasis/proc/dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	switch(new_dir)
		if(WEST, NORTH)
			buckle_lying = 270
		if(EAST, SOUTH)
			buckle_lying = 90

/obj/machinery/stasis/nap_violation(mob/violator)
	unbuckle_mob(violator, TRUE)

/obj/machinery/stasis/attack_robot(mob/user)
	if(Adjacent(user) && occupant)
		unbuckle_mob(occupant)
	else
		..()
#undef STASIS_TOGGLE_COOLDOWN
