#define STASIS_TOGGLE_COOLDOWN 50
/obj/machinery/stasis
	name = "lifeform stasis unit"
	desc = "A not-so-comfortable looking bed with nozzles on top and bottom. Placing someone here will suspend their vital processes, putting them in stasis until removed."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "stasis"
	density = FALSE
	obj_flags = BLOCKS_CONSTRUCTION
	can_buckle = TRUE
	buckle_lying = 90
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
/obj/machinery/stasis/Initialize(mapload)
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed))
	dir_changed(new_dir = dir)
	. = ..()
	initial_link()

/obj/machinery/stasis/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed))
	. = ..()
	if(op_computer?.sbed == src)
		op_computer.sbed = null

/obj/machinery/stasis/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to [stasis_enabled ? "turn off" : "turn on"] the machine.")
	if(op_computer)
		. += span_notice("[src] is <b>linked</b> to an operating computer to the [dir2text(get_dir(src, op_computer))].")
	else
		. += span_notice("[src] is <b>NOT linked</b> to an operating computer.")

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

/obj/machinery/stasis/atom_break(damage_flag)
	. = ..()
	if(.)
		play_power_sound()

/obj/machinery/stasis/power_change()
	. = ..()
	play_power_sound()

/obj/machinery/stasis/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	//we could check inherent_traits, but thats too many var defines. KISS principle.
	if(HAS_TRAIT(target, TRAIT_NOSTASIS))
		return
	target.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	target.ExtinguishMob()
	update_use_power(ACTIVE_POWER_USE)

/obj/machinery/stasis/proc/thaw_them(mob/living/target)
	target.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	if(target == occupant)
		update_use_power(IDLE_POWER_USE)

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
	if(!(occupant && isliving(occupant) && check_nap_violations()))
		update_use_power(IDLE_POWER_USE)
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

REGISTER_BUFFER_HANDLER(/obj/machinery/stasis)

DEFINE_BUFFER_HANDLER(/obj/machinery/stasis)
	if(!panel_open)
		to_chat(user, span_warning("\The [src]'s panel must be open in order to add it to \the [buffer_parent]'s buffer."))
		return NONE
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, span_notice("You store the linking data of \the [src] in \the [buffer_parent]'s buffer. Use it on an operating computer to complete linking."))
		balloon_alert(user, "saved in buffer")
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/stasis/wrench_act(mob/living/user, obj/item/I) //We want to rotate, but we need to do it in 180 degree rotations.
	if(panel_open && has_buckled_mobs())
		to_chat(user, span_notice("\The [src] is too heavy to rotate while someone is buckled to it!"))
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

#undef STASIS_TOGGLE_COOLDOWN
