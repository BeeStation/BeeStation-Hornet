/datum/ai_behavior/battle_screech/monkey
	screeches = list("roar","screech")

/datum/ai_behavior/monkey_equip
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/monkey_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		controller.set_blackboard_key_assoc(BB_MONKEY_BLACKLISTITEMS, controller.blackboard[BB_MONKEY_PICKUPTARGET], TRUE)

	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_equip/proc/equip_item(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/best_force = controller.blackboard[BB_MONKEY_BEST_FORCE_FOUND]

	if(!isturf(living_pawn.loc))
		finish_action(controller, FALSE)
		return

	if(!target)
		finish_action(controller, FALSE)
		return

	if(target.anchored) //Can't pick it up, so stop trying.
		finish_action(controller, FALSE)
		return

	// Strong weapon
	else if(target.force > best_force)
		living_pawn.drop_all_held_items()
		living_pawn.put_in_hands(target)
		controller.set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, target.force)
		finish_action(controller, TRUE)
		return

	else if(target.slot_flags) //Clothing == top priority
		living_pawn.dropItemToGround(target, TRUE)
		living_pawn.update_icons()
		if(!living_pawn.equip_to_appropriate_slot(target))
			finish_action(controller, FALSE)
			return //Already wearing something, in the future this should probably replace the current item but the code didn't actually do that, and I dont want to support it right now.
		finish_action(controller, TRUE)
		return

	// EVERYTHING ELSE
	else if(living_pawn.get_empty_held_indexes())
		living_pawn.put_in_hands(target)
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/monkey_equip/ground
	required_distance = 0

/datum/ai_behavior/monkey_equip/ground/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	equip_item(controller)

/datum/ai_behavior/monkey_equip/pickpocket

/datum/ai_behavior/monkey_equip/pickpocket/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_MONKEY_PICKPOCKETING]) //We are pickpocketing, don't do ANYTHING!!!!
		return
	INVOKE_ASYNC(src, PROC_REF(attempt_pickpocket), controller)

/datum/ai_behavior/monkey_equip/pickpocket/proc/attempt_pickpocket(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[BB_MONKEY_PICKUPTARGET]
	var/mob/living/victim = target.loc
	var/mob/living/living_pawn = controller.pawn

	if(!istype(victim))
		finish_action(controller, FALSE)
		return



	victim.visible_message(span_warning("[living_pawn] starts trying to take [target] from [victim]!"), span_danger("[living_pawn] tries to take [target]!"))

	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, TRUE)

	var/success = FALSE

	if(do_after(living_pawn, MONKEY_ITEM_SNATCH_DELAY, victim) && target && living_pawn.CanReach(victim))

		for(var/obj/item/I in victim.held_items)
			if(I == target)
				victim.visible_message(span_danger("[living_pawn] snatches [target] from [victim]."), span_userdanger("[living_pawn] snatched [target]!"))
				if(victim.temporarilyRemoveItemFromInventory(target))
					if(!QDELETED(target) && !equip_item(controller))
						target.forceMove(living_pawn.drop_location())
						success = TRUE
						break
				else
					victim.visible_message(span_danger("[living_pawn] tried to snatch [target] from [victim], but failed!"), span_userdanger("[living_pawn] tried to grab [target]!"))

	finish_action(controller, success) //We either fucked up or got the item.

/datum/ai_behavior/monkey_equip/pickpocket/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.set_blackboard_key(BB_MONKEY_PICKPOCKETING, FALSE)
	controller.clear_blackboard_key(BB_MONKEY_PICKUPTARGET)

/datum/ai_behavior/monkey_flee

/datum/ai_behavior/monkey_flee/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.health >= MONKEY_FLEE_HEALTH)
		finish_action(controller, TRUE) //we're back in bussiness
		return

	var/mob/living/target = null

	// flee from anyone who attacked us and we didn't beat down
	for(var/mob/living/L in view(living_pawn, MONKEY_FLEE_VISION))
		if(controller.blackboard[BB_MONKEY_ENEMIES][L] && L.stat == CONSCIOUS)
			target = L
			break

	if(target)
		walk_away(living_pawn, target, MONKEY_ENEMY_VISION, 5)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/monkey_attack_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/monkey_attack_mob/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/monkey_attack_mob/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn

	if(!target || target.stat != CONSCIOUS)
		finish_action(controller, TRUE) //Target == owned
		return

	if(isturf(target.loc) && !IS_DEAD_OR_INCAP(living_pawn)) // Check if they're a valid target
		// check if target has a weapon
		var/obj/item/W
		for(var/obj/item/I in target.held_items)
			if(!(I.item_flags & ABSTRACT))
				W = I
				break

		// if the target has a weapon, chance to disarm them
		if(W && DT_PROB(MONKEY_ATTACK_DISARM_PROB, delta_time))
			monkey_attack(controller, target, delta_time, TRUE)
		else
			monkey_attack(controller, target, delta_time, FALSE)


/datum/ai_behavior/monkey_attack_mob/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	SSmove_manager.stop_looping(living_pawn)
	controller.clear_blackboard_key(target_key)

/// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/datum/ai_behavior/monkey_attack_mob/proc/monkey_attack(datum/ai_controller/controller, mob/living/target, delta_time, disarm)
	var/mob/living/living_pawn = controller.pawn

	if(living_pawn.next_move > world.time)
		return

	living_pawn.changeNext_move(CLICK_CD_MELEE) //We play fair

	var/obj/item/weapon = locate(/obj/item) in living_pawn.held_items

	living_pawn.face_atom(target)

	living_pawn.set_combat_mode(TRUE)

	if(isnull(controller.blackboard[BB_MONKEY_GUN_WORKED]))
		controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE)

	// attack with weapon if we have one
	if(living_pawn.CanReach(target, weapon))
		if(weapon)
			weapon.melee_attack_chain(living_pawn, target)
		else
			living_pawn.UnarmedAttack(target, null, disarm ? list("right" = TRUE) : null) //Fake a right click if we're disarmin
		controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE) // We reset their memory of the gun being 'broken' if they accomplish some other attack
	else if(weapon)
		var/atom/real_target = target
		if(prob(10)) // Artificial miss
			real_target = pick(oview(2, target))

		var/obj/item/gun/gun = locate() in living_pawn.held_items
		var/can_shoot = gun?.can_shoot() || FALSE
		if(gun && controller.blackboard[BB_MONKEY_GUN_WORKED] && prob(95))
			// We attempt to attack even if we can't shoot so we get the effects of pulling the trigger
			gun.afterattack(real_target, living_pawn, FALSE)
			controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, can_shoot ? TRUE : prob(80)) // Only 20% likely to notice it didn't work
			if(can_shoot)
				controller.set_blackboard_key(BB_MONKEY_GUN_NEURONS_ACTIVATED, TRUE)
		else
			living_pawn.throw_item(real_target)
			controller.set_blackboard_key(BB_MONKEY_GUN_WORKED, TRUE) // 'worked'

	// no de-aggro
	if(controller.blackboard[BB_MONKEY_AGGRESSIVE])
		return

	// we've queued up a monkey attack on a mob which isn't already an enemy, so give them 1 threat to start
	// note they might immediately reduce threat and drop from the list.
	// this is fine, we're just giving them a love tap then leaving them alone.
	// unless they fight back, then we retaliate
	if(isnull(controller.blackboard[BB_MONKEY_ENEMIES][target]))
		controller.set_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, 1)

	/// mob refs are uids, so this is safe
	if(DT_PROB(MONKEY_HATRED_REDUCTION_PROB, delta_time))
		controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, target, -1)

	// if we are not angry at our target, go back to idle
	if(controller.blackboard[BB_MONKEY_ENEMIES][target] <= 0)
		controller.remove_thing_from_blackboard_key(BB_MONKEY_ENEMIES, target)
		if(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] == target)
			finish_action(controller, TRUE)

/datum/ai_behavior/disposal_mob
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM //performs to increase frustration

/datum/ai_behavior/disposal_mob/setup(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[attack_target_key])

/datum/ai_behavior/disposal_mob/finish_action(datum/ai_controller/controller, succeeded, attack_target_key, disposal_target_key)
	. = ..()
	controller.clear_blackboard_key(attack_target_key) //Reset attack target
	controller.set_blackboard_key(BB_MONKEY_DISPOSING, FALSE) //No longer disposing
	controller.clear_blackboard_key(disposal_target_key) //No target disposal

/datum/ai_behavior/disposal_mob/perform(delta_time, datum/ai_controller/controller, attack_target_key, disposal_target_key)
	. = ..()

	if(controller.blackboard[BB_MONKEY_DISPOSING]) //We are disposing, don't do ANYTHING!!!!
		return

	var/mob/living/target = controller.blackboard[attack_target_key]
	var/mob/living/living_pawn = controller.pawn

	set_movement_target(controller, target)

	if(!target)
		finish_action(controller, FALSE)
		return

	if(target.pulledby != living_pawn && !HAS_AI_CONTROLLER_TYPE(target.pulledby, /datum/ai_controller/monkey)) //Dont steal from my fellow monkeys.
		if(living_pawn.Adjacent(target) && isturf(target.loc))
			target.grabbedby(living_pawn)
		return //Do the rest next turn

	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]
	set_movement_target(controller, disposal)

	if(!disposal)
		finish_action(controller, FALSE)
		return

	if(living_pawn.Adjacent(disposal))
		INVOKE_ASYNC(src, PROC_REF(try_disposal_mob), controller, attack_target_key, disposal_target_key) //put him in!
	else //This means we might be getting pissed!
		return

/datum/ai_behavior/disposal_mob/proc/try_disposal_mob(datum/ai_controller/controller, attack_target_key, disposal_target_key)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[attack_target_key]
	var/obj/machinery/disposal/disposal = controller.blackboard[disposal_target_key]

	controller.set_blackboard_key(BB_MONKEY_DISPOSING, TRUE)

	if(target && disposal?.stuff_mob_in(target, living_pawn))
		disposal.flush()
	finish_action(controller, TRUE, attack_target_key, disposal_target_key)


/datum/ai_behavior/recruit_monkeys/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/nearby_monkey in view(living_pawn, MONKEY_ENEMY_VISION))
		if(!HAS_AI_CONTROLLER_TYPE(nearby_monkey, /datum/ai_controller/monkey))
			continue
		if(!DT_PROB(MONKEY_RECRUIT_PROB, delta_time))
			continue
		// Recruited a monkey to our side
		controller.set_blackboard_key(BB_MONKEY_RECRUIT_COOLDOWN, world.time + MONKEY_RECRUIT_COOLDOWN)
		// Other monkeys now also hate the guy we're currently targeting
		nearby_monkey.ai_controller.add_blackboard_key_assoc(BB_MONKEY_ENEMIES, controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET], MONKEY_RECRUIT_HATED_AMOUNT)

	finish_action(controller, TRUE)

/datum/ai_behavior/monkey_set_combat_target/perform(delta_time, datum/ai_controller/controller, set_key, enemies_key)
	var/list/enemies = controller.blackboard[enemies_key]
	var/list/valids = list()
	for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, controller.pawn))
		if(possible_enemy == controller.pawn)
			continue // don't target ourselves
		if(!enemies[possible_enemy]) //We don't hate this creature! But we might still attack it!
			if(!controller.blackboard[BB_MONKEY_AGGRESSIVE]) //We are not aggressive either, so we won't attack!
				continue
			if(HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey) && !controller.blackboard[BB_MONKEY_TARGET_MONKEYS]) //Do not target poor monkes
				continue
		// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
		valids[possible_enemy] = CEILING(100 / (get_dist(controller.pawn, possible_enemy) || 1), 1)

	if(!length(valids))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(set_key, pick_weight(valids))
	finish_action(controller, TRUE)
