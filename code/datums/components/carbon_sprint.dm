/datum/component/carbon_sprint
	var/mob/living/carbon/carbon_parent
	var/sprint_key_down = FALSE
	var/sprinting = FALSE
	///The move intent to go back to when we stop sprinting
	var/datum/move_intent/pre_sprint_intent
	var/sustained_moves = 0
	///Distance of the step in progress, roughly 1.4 for diagonals
	var/step_size = 1
	var/last_dust
	///Our very own dust
	var/obj/effect/sprint_dust/dust = new(null)

/datum/component/carbon_sprint/Destroy(force, silent)
	QDEL_NULL(dust)
	return ..()

/datum/component/carbon_sprint/RegisterWithParent()
	. = ..()
	carbon_parent = parent
	RegisterSignal(carbon_parent, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(onMobMove))
	RegisterSignal(carbon_parent, COMSIG_MOB_CLIENT_MOVED, PROC_REF(onMobMoved))
	RegisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_DOWN, PROC_REF(keyDown))
	RegisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_UP,  PROC_REF(keyUp))
	//Swapping bodies etcetera can break keypresses :P
	RegisterSignal(carbon_parent, COMSIG_MOB_LOGOUT, PROC_REF(keyUp))

/datum/component/carbon_sprint/UnregisterFromParent()
	. = ..()
	UnregisterSignal(carbon_parent, COMSIG_MOB_CLIENT_PRE_MOVE)
	UnregisterSignal(carbon_parent, COMSIG_MOB_CLIENT_MOVED)
	UnregisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_DOWN)
	UnregisterSignal(carbon_parent, COMSIG_KB_CARBON_SPRINT_UP)
	UnregisterSignal(carbon_parent, COMSIG_MOB_LOGOUT)

/datum/component/carbon_sprint/proc/onMobMove(datum/source, list/move_args)
	var/direct = move_args[MOVE_ARG_DIRECTION]
	if((SEND_SIGNAL(carbon_parent, COMSIG_CARBON_PRE_SPRINT) & INTERRUPT_SPRINT) || !can_sprint())
		if(sprinting)
			stopSprint()
		return

	step_size = (direct & (direct-1)) ? 1.4 : 1

	var/turf/T = move_args[MOVE_ARG_NEW_LOC]
	if(!isturf(T))
		return
	if(T.is_blocked_turf(source_atom = parent))
		return

	if(!MOVING_QUICKLY(carbon_parent))
		pre_sprint_intent = carbon_parent.move_intent
		carbon_parent.set_move_intent(carbon_parent.get_move_intent_by_flag(MOVE_INTENT_QUICK))

	if(!sprinting)
		sprinting = TRUE
		dust.appear("sprint_cloud", direct, get_turf(carbon_parent), 0.6 SECONDS)
		last_dust = world.time
		sustained_moves += step_size

	else if(world.time > last_dust + STAMINA_SUSTAINED_RUN_GRACE)
		if(direct & carbon_parent.last_move)
			if((sustained_moves < STAMINA_SUSTAINED_SPRINT_THRESHOLD) && ((sustained_moves + step_size) >= STAMINA_SUSTAINED_SPRINT_THRESHOLD))
				dust.appear("sprint_cloud_small", direct, get_turf(carbon_parent), 0.4 SECONDS)
				last_dust = world.time
			sustained_moves += step_size

		else
			if(sustained_moves >= STAMINA_SUSTAINED_SPRINT_THRESHOLD)
				dust.appear("sprint_cloud_small", direct, get_turf(carbon_parent), 0.4 SECONDS)
				last_dust = world.time
			if(direct & turn(carbon_parent.last_move, 180))
				dust.appear("sprint_cloud_tiny", direct, get_turf(carbon_parent), 0.3 SECONDS)
				last_dust = world.time
			sustained_moves = 0

///subtract stamina after the move happened
/datum/component/carbon_sprint/proc/onMobMoved(datum/source)
	if(!sprinting || !MOVING_QUICKLY(carbon_parent))
		return
	var/cost = STAMINA_SPRINT_COST * step_size
	if(carbon_parent.has_movespeed_modifier(/datum/movespeed_modifier/bulky_drag) || carbon_parent.has_movespeed_modifier(/datum/movespeed_modifier/human_carry))
		cost *= STAMINA_SPRINT_HAUL_MODIFIER
	carbon_parent.stamina.adjust(-cost, TRUE)
	carbon_parent.stamina.block_regen(STAMINA_SPRINT_REGEN_DELAY)

/datum/component/carbon_sprint/proc/keyDown()
	sprint_key_down = TRUE

/datum/component/carbon_sprint/proc/keyUp()
	sprint_key_down = FALSE

/datum/component/carbon_sprint/proc/stopSprint()
	sprinting = FALSE
	sustained_moves = FALSE
	last_dust = null
	if(MOVING_QUICKLY(carbon_parent))
		carbon_parent.set_move_intent(pre_sprint_intent || /datum/move_intent/run)
	pre_sprint_intent = null

/datum/component/carbon_sprint/proc/can_sprint()
	. = TRUE

	if(!sprint_key_down)
		return FALSE

	if(carbon_parent.movement_type & (FLOATING|FLYING|VENTCRAWLING|PHASING))
		return FALSE

	var/datum/move_intent/quick_intent = carbon_parent.get_move_intent_by_flag(MOVE_INTENT_QUICK)
	if(!quick_intent?.can_be_used_by(carbon_parent))
		return FALSE

	if(HAS_TRAIT(carbon_parent, TRAIT_STAMINA_DRAINS_POWER))
		return !!(SEND_SIGNAL(carbon_parent, COMSIG_LIVING_DRAIN_STAMINA_POWER, 0, FALSE) & COMPONENT_STAMINA_POWERED)

	//At zero a step costs nothing and never rolls a stamina stun, so a second wind would sprint forever
	if(carbon_parent.stamina.current <= 0)
		return FALSE
