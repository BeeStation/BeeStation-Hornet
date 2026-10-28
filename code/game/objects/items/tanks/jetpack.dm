/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = /datum/gas/oxygen
	var/on = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	var/stabilize = FALSE
	var/thrust_callback
	var/use_ion_trail = TRUE

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_SUITSTORE)
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	configure_jetpack(stabilize)

/obj/item/tank/jetpack/Destroy()
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilize - Should this jetpack be stabalized
 */
/obj/item/tank/jetpack/proc/configure_jetpack(stabilize)
	src.stabilize = stabilize

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_JETPACK_ACTIVATED, \
		COMSIG_JETPACK_DEACTIVATED, \
		JETPACK_ACTIVATION_FAILED, \
		thrust_callback, \
		use_ion_trail ? /datum/effect_system/trail_follow/ion : null \
	)

/obj/item/tank/jetpack/item_action_slot_check(slot)
	if(slot & slot_flags)
		return TRUE

/obj/item/tank/jetpack/equipped(mob/user, slot, initial)
	. = ..()
	if(on && !(slot & slot_flags))
		turn_off(user)

/obj/item/tank/jetpack/dropped(mob/user, silent)
	. = ..()
	if(on)
		turn_off(user)

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		var/datum/gas_mixture/our_mix = return_air()
		our_mix.set_gas(gas_type, ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))

/obj/item/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			configure_jetpack(!stabilize)
			to_chat(user, span_notice("You turn the jetpack stabilization [stabilize ? "on" : "off"]."))
	else
		toggle_internals(user)

/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated)
		return

	if(!on)
		if(turn_on(user))
			to_chat(user, span_notice("You turn the jetpack on."))
		else
			to_chat(user, span_notice("You fail to turn the jetpack on."))
			return
	else
		turn_off(user)
		to_chat(user, span_notice("You turn the jetpack off."))

	update_action_buttons()

/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(SEND_SIGNAL(src, COMSIG_JETPACK_ACTIVATED, user) & JETPACK_ACTIVATION_FAILED)
		return FALSE
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	if(full_speed)
		user.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)
	return TRUE

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	SEND_SIGNAL(src, COMSIG_JETPACK_DEACTIVATED, user)
	on = FALSE
	icon_state = initial(icon_state)
	if(user)
		user.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/tank/jetpack/proc/allow_thrust(num, use_fuel = TRUE)
	if(!ismob(loc))
		return FALSE
	var/mob/user = loc

	if((num < 0.005 || num > THRUST_REQUIREMENT_GRAVITY * 0.5 || air_contents.total_moles() < num))
		turn_off(user)
		return FALSE

	// We've got the gas, it's chill
	if(!use_fuel)
		return TRUE

	remove_air(num)

	return TRUE

/obj/item/tank/jetpack/suicide_act(mob/living/user)
	if (!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.say(";WHAT THE FUCK IS CARBON DIOXIDE?", forced="jetpack suicide")
	H.visible_message(span_suicide("[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!"))
	return OXYLOSS

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	inhand_icon_state = "jetpack-sec"
	worn_icon = null
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE //moves at hardsuit jetpack speeds

/obj/item/tank/jetpack/improvised/allow_thrust(num)
	if(!ismob(loc))
		return FALSE
	var/mob/user = loc
	if(rand(0,250) == 0)
		to_chat(user, span_notice("You feel your jetpack's engines cut out."))
		turn_off(user)
		return
	return ..()

/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	inhand_icon_state =  "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	inhand_icon_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	inhand_icon_state = "jetpack-black"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT

/obj/item/tank/jetpack/oxygen/captain
	name = "captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	inhand_icon_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_LARGE
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/tank/jetpack/oxygen/captain/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/trackable)

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	inhand_icon_state = "jetpack-sec"

/obj/item/tank/jetpack/combustion
	name = "rocket jetpack"
	desc = "A jetpack capable of powerful flight, strong enough to counteract the effects of gravity. Uses the high energy output of plasma combustion to generate enough thrust."
	icon_state = "jetpack-rocket"
	inhand_icon_state =  "jetpack-rocket"
	gas_type = null
	use_ion_trail = FALSE
	var/gravity_joules = 10000
	var/obj/emitter/single_left_emitter
	var/obj/emitter/single_right_emitter
	var/obj/emitter/left_emitter
	var/obj/emitter/right_emitter
	var/tilt_timer = 0
	/// The mob the flame emitters are attached to while we're on
	var/mob/jet_user

/obj/item/tank/jetpack/combustion/Initialize(mapload)
	. = ..()
	single_left_emitter = new /obj/emitter/fire_jet/single/left
	single_right_emitter = new /obj/emitter/fire_jet/single/right
	left_emitter = new /obj/emitter/fire_jet/left
	right_emitter = new /obj/emitter/fire_jet/right

/obj/item/tank/jetpack/combustion/Destroy()
	if(jet_user)
		turn_off(jet_user)
	return ..()

/obj/item/tank/jetpack/combustion/proc/on_user_dir_change(atom/thing, old_dir, new_dir)
	SIGNAL_HANDLER
	if(new_dir == old_dir)
		return
	if(new_dir == EAST)
		single_left_emitter.vis_locs |= thing
		single_right_emitter.vis_locs -= thing
		left_emitter.vis_locs -= thing
		right_emitter.vis_locs -= thing
	else if(new_dir == WEST)
		single_left_emitter.vis_locs -= thing
		single_right_emitter.vis_locs |= thing
		left_emitter.vis_locs -= thing
		right_emitter.vis_locs -= thing
	else if(new_dir == NORTH || new_dir == SOUTH)
		single_left_emitter.vis_locs -= thing
		single_right_emitter.vis_locs -= thing
		left_emitter.vis_locs |= thing
		right_emitter.vis_locs |= thing
	if(new_dir == SOUTH)
		single_left_emitter.layer = BELOW_MOB_LAYER
		single_right_emitter.layer = BELOW_MOB_LAYER
		left_emitter.layer = BELOW_MOB_LAYER
		right_emitter.layer = BELOW_MOB_LAYER
		single_left_emitter.vis_flags = VIS_INHERIT_PLANE
		single_right_emitter.vis_flags = VIS_INHERIT_PLANE
		left_emitter.vis_flags = VIS_INHERIT_PLANE
		right_emitter.vis_flags = VIS_INHERIT_PLANE
	else
		single_left_emitter.layer = ABOVE_MOB_LAYER
		single_right_emitter.layer = ABOVE_MOB_LAYER
		left_emitter.layer = ABOVE_MOB_LAYER
		right_emitter.layer = ABOVE_MOB_LAYER
		single_left_emitter.plane = ABOVE_LIGHTING_PLANE
		single_right_emitter.plane = ABOVE_LIGHTING_PLANE
		left_emitter.plane = ABOVE_LIGHTING_PLANE
		right_emitter.plane = ABOVE_LIGHTING_PLANE
		single_left_emitter.vis_flags = NONE
		single_right_emitter.vis_flags = NONE
		left_emitter.vis_flags = NONE
		right_emitter.vis_flags = NONE

/obj/item/tank/jetpack/combustion/proc/update_particle_counts(amount)
	single_left_emitter.particles.count = amount * 2
	single_right_emitter.particles.count = amount * 2
	left_emitter.particles.count = amount
	right_emitter.particles.count = amount

/obj/item/tank/jetpack/combustion/proc/update_fade(fade)
	single_left_emitter.particles.fade = fade
	single_right_emitter.particles.fade = fade
	left_emitter.particles.fade = fade
	right_emitter.particles.fade = fade

/obj/item/tank/jetpack/combustion/proc/update_lifespan(lifespan)
	single_left_emitter.particles.lifespan = lifespan
	single_right_emitter.particles.lifespan = lifespan
	left_emitter.particles.lifespan = lifespan
	right_emitter.particles.lifespan = lifespan

/obj/item/tank/jetpack/combustion/turn_on(mob/user)
	. = ..()
	if(!.)
		return
	jet_user = user
	on_user_dir_change(user, null, user.dir)
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_user_dir_change))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))
	update_particle_counts(100)
	update_fade(100)
	update_lifespan(3)

/obj/item/tank/jetpack/combustion/turn_off(mob/user)
	..()
	update_particle_counts(0)
	if(!jet_user)
		return
	single_left_emitter.vis_locs -= jet_user
	single_right_emitter.vis_locs -= jet_user
	left_emitter.vis_locs -= jet_user
	right_emitter.vis_locs -= jet_user
	UnregisterSignal(jet_user, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_MOVED))
	jet_user = null

/obj/item/tank/jetpack/combustion/proc/on_user_moved(mob/user)
	SIGNAL_HANDLER
	var/turf/user_loc = get_turf(user)
	if(!isopenspace(user_loc))
		update_fade(100)
		update_lifespan(3)
		update_particle_counts(100)
	// tilt animation
	else if(user.dir == EAST || user.dir == WEST)
		var/matrix/M = matrix()
		M.Turn(user.dir == EAST ? 15 : -15)
		if(tilt_timer)
			deltimer(tilt_timer)
		animate(user, transform = M, time = 2)
		tilt_timer = addtimer(CALLBACK(src, PROC_REF(reset_animation), user), 2, TIMER_STOPPABLE)

/obj/item/tank/jetpack/combustion/proc/reset_animation(mob/who)
	animate(who, transform = null, time = 2)

/obj/item/tank/jetpack/combustion/populate_gas()
	var/datum/gas_mixture/our_mix = return_air()
	var/moles_full = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))
	var/ideal_o2_percent = (1 / PLASMA_OXYGEN_FULLBURN) * 2
	our_mix.set_gas(/datum/gas/plasma, moles_full * (1 - ideal_o2_percent))
	our_mix.set_gas(/datum/gas/oxygen, moles_full * ideal_o2_percent)

/obj/item/tank/jetpack/combustion/allow_thrust(num, use_fuel = TRUE)
	if(!ismob(loc))
		return FALSE
	var/mob/user = loc
	if(num < 0.005)
		turn_off(user)
		return

	var/potential_energy = 0
	var/datum/gas_mixture/our_mix = return_air()
	// Minified version of plasmafire burn reaction, with a "controlled" burnrate adjustment due to the high energy output of the reaction
	// Also produces no waste products (CO2/Trit)
	var/oxygen_burn_rate = (OXYGEN_BURN_RATE_BASE - 1)
	var/plasma_burn_rate = 0

	var/oxygen_moles = our_mix.moles[/datum/gas/oxygen] || 0
	var/plasma_moles = our_mix.moles[/datum/gas/plasma] || 0

	if(oxygen_moles > plasma_moles * PLASMA_OXYGEN_FULLBURN)
		plasma_burn_rate = plasma_moles / PLASMA_BURN_RATE_DELTA
	else
		plasma_burn_rate = (plasma_moles / PLASMA_OXYGEN_FULLBURN)/PLASMA_BURN_RATE_DELTA
	if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
		plasma_burn_rate = min(plasma_burn_rate, plasma_moles, oxygen_moles / oxygen_burn_rate) //Ensures matter is conserved properly
		potential_energy = FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

	// Normalize thrust volume to joules
	var/energy_required = GRAVITY_JOULE_REQUIREMENT * ((1 / THRUST_REQUIREMENT_GRAVITY) * num)
	if(potential_energy < energy_required)
		return
	// Only burn as much as we need to produce the energy, then increase consumption by a lot
	var/burn_rate_adjustment = (energy_required / potential_energy) * JETPACK_COMBUSTION_CONSUMPTION_ADJUSTMENT
	plasma_burn_rate *= burn_rate_adjustment
	oxygen_burn_rate *= burn_rate_adjustment

	// Consume
	if(use_fuel)
		our_mix.set_gas(/datum/gas/plasma, QUANTIZE(plasma_moles - plasma_burn_rate))
		our_mix.set_gas(/datum/gas/oxygen, QUANTIZE(oxygen_moles - (plasma_burn_rate * oxygen_burn_rate)))
	update_fade(1.5 SECONDS)
	update_lifespan(0.4 SECONDS)

	return TRUE

/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	inhand_icon_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = /datum/gas/carbon_dioxide

/// Attempts to use jetpack power for z-level movement in gravity
/mob/living/proc/has_jetpack_power(thrust, use_fuel = TRUE)
	return FALSE

/mob/living/carbon/has_jetpack_power(thrust, use_fuel = TRUE)
	var/obj/item/organ/cyberimp/chest/thrusters/thrusters = get_organ_slot(ORGAN_SLOT_THRUSTERS)
	if(istype(thrusters) && thrusters.allow_thrust(thrust, use_fuel))
		return TRUE

	var/obj/item/tank/jetpack/jetpack = get_jetpack()
	return jetpack?.on && jetpack.allow_thrust(thrust, use_fuel)

/// Returns the jetpack worn on this mob's back, if any
/mob/living/carbon/proc/get_jetpack()
	var/obj/item/tank/jetpack/jetpack = back
	if(istype(jetpack))
		return jetpack
