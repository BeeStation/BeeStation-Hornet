/obj/item/tank/jetpack
	name = "jetpack (empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = GAS_O2
	var/on = FALSE
	var/stabilizers = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	var/datum/effect_system/trail_follow/ion/ion_trail
	var/use_ion_trail = TRUE
	/// The user that this jetpack is expected to have
	var/mob/known_user

/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	if(use_ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

/obj/item/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		air_contents.set_moles(gas_type, ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))

/obj/item/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			stabilizers = !stabilizers
			to_chat(user, "<span class='notice'>You turn the jetpack stabilization [stabilizers ? "on" : "off"].</span>")
	else
		toggle_internals(user)


/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		turn_on(user)
		to_chat(user, "<span class='notice'>You turn the jetpack on.</span>")
	else
		turn_off(user)
		to_chat(user, "<span class='notice'>You turn the jetpack off.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/tank/jetpack/equipped(mob/user, slot)
	..()
	if(slot_flags & slot)
		update_known_user(user)
	else
		lose_known_user()

/obj/item/tank/jetpack/dropped(mob/user)
	..()
	lose_known_user()

/obj/item/tank/jetpack/proc/update_known_user(mob/user)
	if(user == known_user)
		return
	if(known_user)
		lose_known_user()
	known_user = user
	if(known_user)
		on_user_add()

/obj/item/tank/jetpack/proc/on_user_add()
	RegisterSignal(known_user, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
	RegisterSignal(known_user, COMSIG_PARENT_QDELETING, PROC_REF(lose_known_user))

/obj/item/tank/jetpack/proc/lose_known_user()
	SIGNAL_HANDLER
	if(known_user)
		on_user_loss()
	known_user = null

/obj/item/tank/jetpack/proc/on_user_loss()
	known_user.remove_movespeed_modifier(MOVESPEED_ID_JETPACK)
	UnregisterSignal(known_user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(known_user, COMSIG_PARENT_QDELETING)

/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(!known_user)
		return
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	if(ion_trail)
		ion_trail.start()
	if(full_speed)
		known_user.add_movespeed_modifier(MOVESPEED_ID_JETPACK, priority=100, multiplicative_slowdown=-2, movetypes=FLOATING, conflict=MOVE_CONFLICT_JETPACK)

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	if(!known_user)
		return
	on = FALSE
	stabilizers = FALSE
	icon_state = initial(icon_state)
	if(ion_trail)
		ion_trail.stop()

	known_user.remove_movespeed_modifier(MOVESPEED_ID_JETPACK)

/obj/item/tank/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER
	if(on)
		allow_thrust(THRUST_REQUIREMENT_SPACEMOVE, user)

/obj/item/tank/jetpack/proc/allow_thrust(num, mob/living/user, use_fuel = TRUE)
	if(!on || !known_user)
		return
	if((num < 0.005 || num > THRUST_REQUIREMENT_GRAVITY * 0.5 || air_contents.total_moles() < num))
		turn_off(user)
		return

	if(use_fuel)
		assume_air_moles(air_contents, num)

	return TRUE

/obj/item/tank/jetpack/suicide_act(mob/user)
	if (istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say(";WHAT THE FUCK IS CARBON DIOXIDE?", forced="jetpack suicide")
		H.visible_message("<span class='suicide'>[user] is suffocating [user.p_them()]self with [src]! It looks like [user.p_they()] didn't read what that jetpack says!</span>")
		return (OXYLOSS)
	else
		..()

/obj/item/tank/jetpack/improvised
	name = "improvised jetpack"
	desc = "A jetpack made from two air tanks, a fire extinguisher and some atmospherics equipment. It doesn't look like it can hold much."
	icon_state = "jetpack-improvised"
	item_state = "jetpack-sec"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE //moves at hardsuit jetpack speeds

/obj/item/tank/jetpack/improvised/allow_thrust(num, mob/living/user, use_fuel = TRUE)
	if(!on || !known_user)
		return
	if((num < 0.005 || THRUST_REQUIREMENT_GRAVITY * 0.5 || air_contents.total_moles() < num))
		turn_off(user)
		return
	if(rand(0,250) == 0)
		to_chat(user, "<span class='notice'>You feel your jetpack's engines cut out.</span>")
		turn_off(user)
		return

	if(use_fuel)
		assume_air_moles(air_contents, num)

	return TRUE

/obj/item/tank/jetpack/void
	name = "void jetpack (oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT

/obj/item/tank/jetpack/oxygen/captain
	name = "\improper Captain's jetpack"
	desc = "A compact, lightweight jetpack containing a high amount of compressed oxygen."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/tank/jetpack/oxygen/security
	name = "security jetpack (oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas by security forces."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"

/obj/item/tank/jetpack/combustion
	name = "rocket jetpack"
	desc = "A jetpack capable of powerful flight, strong enough to counteract the effects of gravity. Uses the high energy output of plasma combustion to generate enough thrust."
	icon_state = "jetpack-rocket"
	item_state =  "jetpack-rocket"
	gas_type = null
	use_ion_trail = FALSE
	var/gravity_joules = 10000
	var/obj/emitter/single_left_emitter
	var/obj/emitter/single_right_emitter
	var/obj/emitter/left_emitter
	var/obj/emitter/right_emitter
	var/tilt_timer = 0

/obj/item/tank/jetpack/combustion/Initialize(mapload)
	. = ..()
	single_left_emitter = new /obj/emitter/fire_jet/single/left
	single_right_emitter = new /obj/emitter/fire_jet/single/right
	left_emitter = new /obj/emitter/fire_jet/left
	right_emitter = new /obj/emitter/fire_jet/right

/obj/item/tank/jetpack/combustion/on_user_add()
	..()
	on_user_dir_change(null, null, known_user.dir)
	RegisterSignal(known_user, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_user_dir_change))

/obj/item/tank/jetpack/combustion/on_user_loss()
	..()
	single_left_emitter.vis_locs -= known_user
	single_right_emitter.vis_locs -= known_user
	left_emitter.vis_locs -= known_user
	right_emitter.vis_locs -= known_user
	UnregisterSignal(known_user, COMSIG_ATOM_DIR_CHANGE)

/obj/item/tank/jetpack/combustion/proc/on_user_dir_change(atom/thing, old_dir, new_dir)
	SIGNAL_HANDLER
	if(new_dir == old_dir)
		return
	if(new_dir == EAST)
		single_left_emitter.vis_locs |= known_user
		single_right_emitter.vis_locs -= known_user
		left_emitter.vis_locs -= known_user
		right_emitter.vis_locs -= known_user
	else if(new_dir == WEST)
		single_left_emitter.vis_locs -= known_user
		single_right_emitter.vis_locs |= known_user
		left_emitter.vis_locs -= known_user
		right_emitter.vis_locs -= known_user
	else if(new_dir == NORTH || new_dir == SOUTH)
		single_left_emitter.vis_locs -= known_user
		single_right_emitter.vis_locs -= known_user
		left_emitter.vis_locs |= known_user
		right_emitter.vis_locs |= known_user
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
	..()
	if(!known_user)
		return
	update_particle_counts(100)
	update_fade(100)
	update_lifespan(3)

/obj/item/tank/jetpack/combustion/turn_off(mob/user)
	..()
	if(!known_user)
		return
	update_particle_counts(0)

/obj/item/tank/jetpack/combustion/move_react(mob/user)
	..()
	if(!on)
		return
	var/turf/user_loc = get_turf(known_user)
	if(!isopenspace(user_loc))
		update_fade(100)
		update_lifespan(3)
		update_particle_counts(on ? 100 : 0)
	// tilt animation
	else if(known_user.dir == EAST || known_user.dir == WEST)
		var/matrix/M = matrix()
		M.Turn(known_user.dir == EAST ? 15 : -15)
		if(tilt_timer)
			deltimer(tilt_timer)
		animate(known_user, transform = M, time = 2)
		tilt_timer = addtimer(CALLBACK(src, PROC_REF(reset_animation), known_user), 2, TIMER_STOPPABLE)

/obj/item/tank/jetpack/combustion/proc/reset_animation(mob/who)
	animate(who, transform = null, time = 2)

/obj/item/tank/jetpack/combustion/populate_gas()
	var/moles_full = ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))
	var/ideal_o2_percent = (1 / PLASMA_OXYGEN_FULLBURN) * 2
	air_contents.set_moles(GAS_PLASMA, moles_full * (1 - ideal_o2_percent))
	air_contents.set_moles(GAS_O2, moles_full * ideal_o2_percent)

/obj/item/tank/jetpack/combustion/allow_thrust(num, mob/living/user, use_fuel = TRUE)
	if(!on || !known_user)
		return
	if(num < 0.005)
		turn_off(user)
		return

	var/potential_energy = 0
	// Minified version of plasmafire burn reaction, with a "controlled" burnrate adjustment due to the high energy output of the reaction
	// Also produces no waste products (CO2/Trit)
	var/oxygen_burn_rate = (OXYGEN_BURN_RATE_BASE - 1)
	var/plasma_burn_rate = 0
	if(air_contents.get_moles(GAS_O2) > air_contents.get_moles(GAS_PLASMA)*PLASMA_OXYGEN_FULLBURN)
		plasma_burn_rate = air_contents.get_moles(GAS_PLASMA)/PLASMA_BURN_RATE_DELTA
	else
		plasma_burn_rate = (air_contents.get_moles(GAS_O2)/PLASMA_OXYGEN_FULLBURN)/PLASMA_BURN_RATE_DELTA
	if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
		plasma_burn_rate = min(plasma_burn_rate,air_contents.get_moles(GAS_PLASMA),air_contents.get_moles(GAS_O2)/oxygen_burn_rate) //Ensures matter is conserved properly
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
		air_contents.set_moles(GAS_PLASMA, QUANTIZE(air_contents.get_moles(GAS_PLASMA) - plasma_burn_rate))
		air_contents.set_moles(GAS_O2, QUANTIZE(air_contents.get_moles(GAS_O2) - (plasma_burn_rate * oxygen_burn_rate)))
	update_fade(15)
	update_lifespan(4)

	return TRUE

/obj/item/tank/jetpack/carbondioxide
	name = "jetpack (carbon dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = GAS_CO2


/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It is fueled by a tank inserted into the suit's storage compartment."
	icon_state = "jetpack-mining"
	item_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/cur_user

/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, "<span class='warning'>\The [src] must be connected to a hardsuit!</span>")
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank/internals))
		to_chat(user, "<span class='warning'>You need a tank in your suit storage!</span>")
		return
	..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return
	var/mob/living/carbon/human/H = user
	tank = H.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	cur_user = user
	..()

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	cur_user = null
	..()

/obj/item/tank/jetpack/suit/process()
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		turn_off(cur_user)
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(cur_user)
		return
	..()

/// Returns any jetpack on this mob that can be used
/mob/proc/get_jetpack()
	return

/// Attempts using jetpack power. movement_dir is if the movement is intentionally in a direction as in SpaceMove
/mob/proc/has_jetpack_power(movement_dir = FALSE, thrust = THRUST_REQUIREMENT_SPACEMOVE, require_stabilization = FALSE, use_fuel = TRUE)
	return FALSE

/mob/living/carbon/has_jetpack_power(movement_dir = FALSE, thrust = THRUST_REQUIREMENT_SPACEMOVE, require_stabilization = FALSE, use_fuel = TRUE)
	var/obj/item/organ/cyberimp/chest/thrusters/T = getorganslot(ORGAN_SLOT_THRUSTERS)
	if(istype(T) && movement_dir && T.allow_thrust(thrust, use_fuel = use_fuel))
		return TRUE

	var/obj/item/tank/jetpack/J = get_jetpack()
	if(istype(J) && (movement_dir || J.stabilizers) && (!require_stabilization || J.stabilizers) && J.allow_thrust(thrust, src, use_fuel = use_fuel))
		return TRUE

/mob/living/carbon/get_jetpack()
	var/obj/item/tank/jetpack/J = back
	if(istype(J))
		return J

/mob/living/carbon/human/get_jetpack()
	var/obj/item/tank/jetpack/J = ..()
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	return J
