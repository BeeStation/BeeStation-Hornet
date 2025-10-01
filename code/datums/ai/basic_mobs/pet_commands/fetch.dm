/**
 * Traverse to a target with the intention of picking it up.
 * If we can't do that, add it to a list of ignored items.
 */
/datum/ai_behavior/fetch_seek
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/fetch_seek/setup(datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/obj/item/fetch_thing = controller.blackboard[target_key]
	// It stopped existing
	if (QDELETED(fetch_thing))
		return FALSE
	set_movement_target(controller, fetch_thing)

/datum/ai_behavior/fetch_seek/perform(delta_time, datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/obj/item/fetch_thing = controller.blackboard[target_key]

	// It stopped existing
	if (QDELETED(fetch_thing))
		finish_action(controller, FALSE, target_key, delivery_key)
		return
	var/mob/living/living_pawn = controller.pawn
	// We can't pick this up
	if (fetch_thing.anchored || !isturf(fetch_thing.loc) || !living_pawn.CanReach(fetch_thing))
		finish_action(controller, FALSE, target_key, delivery_key)
		return

	finish_action(controller, TRUE, target_key, delivery_key)

/datum/ai_behavior/fetch_seek/finish_action(datum/ai_controller/controller, success, target_key, delivery_key)
	. = ..()
	if (success)
		return
	// Blacklist item if we failed
	var/obj/item/target = controller.blackboard[target_key]
	if (target)
		controller.set_blackboard_key_assoc_lazylist(BB_FETCH_IGNORE_LIST, target, TRUE)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(delivery_key)

/**
 * The second half of fetching, deliver the item to a target.
 */
/datum/ai_behavior/deliver_fetched_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/deliver_fetched_item/setup(datum/ai_controller/controller, delivery_key, storage_key)
	. = ..()
	var/mob/living/return_target = controller.blackboard[delivery_key]
	if(QDELETED(return_target)) // Guess it's mine now
		return FALSE
	set_movement_target(controller, return_target)

/datum/ai_behavior/deliver_fetched_item/perform(delta_time, datum/ai_controller/controller, delivery_key, storage_key)
	. = ..()
	var/mob/living/return_target = controller.blackboard[delivery_key]
	if(QDELETED(return_target))
		finish_action(controller, FALSE, delivery_key)
		return

	deliver_item(controller, return_target, storage_key)
	finish_action(controller, TRUE, delivery_key)

/datum/ai_behavior/deliver_fetched_item/finish_action(datum/ai_controller/controller, success, delivery_key)
	. = ..()
	controller.clear_blackboard_key(delivery_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/// Actually deliver the fetched item to the target, if we still have it
/datum/ai_behavior/deliver_fetched_item/proc/deliver_item(datum/ai_controller/controller, return_target, storage_key)
	var/mob/pawn = controller.pawn
	var/obj/item/carried_item = controller.blackboard[storage_key]
	if(QDELETED(carried_item) || carried_item.loc != pawn)
		pawn.visible_message(span_notice("[pawn] looks around as if [pawn.p_they()] [pawn.p_have()] lost something."))
		finish_action(controller, FALSE)
		return

	pawn.visible_message(span_notice("[pawn] delivers [carried_item] to [return_target]."))
	carried_item.forceMove(get_turf(return_target))
	controller.clear_blackboard_key(storage_key)
	return TRUE

/**
 * The alternate second half of fetching, attack the item if we can eat it.
 * Or make pleading eyes at someone who has picked it up.
 *
 * Unfortunately this doesn't work because food can't currently be eaten by mobs.
 */
/datum/ai_behavior/eat_fetched_snack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0.8 SECONDS

/datum/ai_behavior/eat_fetched_snack/setup(datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/obj/item/snack = controller.blackboard[target_key]
	if(!istype(snack) || !IS_EDIBLE(snack) || !(isturf(snack.loc) || ishuman(snack.loc)))
		return FALSE // This isn't food at all!
	set_movement_target(controller, snack)

/datum/ai_behavior/eat_fetched_snack/perform(delta_time, datum/ai_controller/controller, target_key, delivery_key)
	. = ..()
	var/obj/item/snack = controller.blackboard[target_key]
	if(QDELETED(snack) || !isturf(snack.loc) || ishuman(snack.loc))
		finish_action(controller, FALSE) // Where did it go?

	var/mob/living/basic/basic_pawn = controller.pawn
	if(!in_range(basic_pawn, snack))
		return

	if(isturf(snack.loc))
		basic_pawn.melee_attack(snack) // snack attack!
	else if(iscarbon(snack.loc) && DT_PROB(10, delta_time))
		basic_pawn.manual_emote("Stares at [snack.loc]'s [snack.name] intently.")

	if(QDELETED(snack)) // we ate it!
		finish_action(controller, TRUE, target_key, delivery_key)

/datum/ai_behavior/eat_fetched_snack/finish_action(datum/ai_controller/controller, succeeded, target_key, delivery_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(delivery_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/**
 * Clear our failed fetch list every so often
 */
/datum/ai_behavior/forget_failed_fetches
	/// How long to wait between resetting the list
	var/cooldown_duration = AI_FETCH_IGNORE_DURATION
	/// Time until we should forget things we failed to pick up
	COOLDOWN_DECLARE(reset_ignore_cooldown)

/datum/ai_behavior/forget_failed_fetches/setup(datum/ai_controller/controller, ...)
	. = ..()
	if (!COOLDOWN_FINISHED(src, reset_ignore_cooldown))
		return FALSE
	if (!length(controller.blackboard[BB_FETCH_IGNORE_LIST]))
		return

/datum/ai_behavior/forget_failed_fetches/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	COOLDOWN_START(src, reset_ignore_cooldown, cooldown_duration)
	controller.clear_blackboard_key(BB_FETCH_IGNORE_LIST)
	finish_action(controller, TRUE)
