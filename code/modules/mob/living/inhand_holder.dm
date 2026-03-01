//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/mob_holder
	name = "bugged mob"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	slot_flags = NONE
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	/// Mob inside of us
	var/mob/living/held_mob

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/mob_holder)

/obj/item/mob_holder/Initialize(mapload, mob/living/held_mob, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	if(head_icon)
		worn_icon = head_icon
	if(worn_state)
		inhand_icon_state = worn_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(worn_slot_flags)
		slot_flags = worn_slot_flags
	w_class = held_mob.held_w_class
	insert_mob(held_mob)
	return ..()

/obj/item/mob_holder/Destroy()
	if(held_mob?.loc == src)
		release()
	held_mob = null
	return ..()

/obj/item/mob_holder/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !held_mob) //overriden or mob missing
		return
	user.UnarmedAttack(held_mob, proximity_flag = TRUE, modifiers = modifiers)

/obj/item/mob_holder/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(. || !held_mob) // Another interaction was performed
		return
	attacking_item.melee_attack_chain(user, held_mob) //Interact with the mob with our tool


/obj/item/mob_holder/proc/insert_mob(mob/living/new_prisoner)
	if(!istype(new_prisoner))
		return FALSE
	new_prisoner.setDir(SOUTH)
	update_visuals(new_prisoner)
	held_mob = new_prisoner
	RegisterSignal(held_mob, COMSIG_QDELETING, PROC_REF(on_mob_deleted))
	new_prisoner.forceMove(src)
	name = new_prisoner.name
	desc = new_prisoner.desc
	return TRUE

/obj/item/mob_holder/proc/on_mob_deleted()
	SIGNAL_HANDLER
	held_mob = null
	if (isliving(loc))
		var/mob/living/holder = loc
		holder.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)

/obj/item/mob_holder/proc/update_visuals(mob/living/held_guy)
	appearance = held_guy.appearance

/obj/item/mob_holder/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		release()
		return

	var/mob/living/throw_mob = held_mob
	release()
	return throw_mob

/obj/item/mob_holder/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(held_mob && isturf(loc))
		release()

/obj/item/mob_holder/proc/release(display_messages = TRUE, delete_mob = FALSE)
	if(!held_mob)
		if(!QDELETED(src))
			qdel(src)
		return FALSE
	var/mob/living/released_mob = held_mob
	if(isliving(loc))
		var/mob/living/captor = loc
		if(display_messages)
			to_chat(captor, span_warning("[released_mob] wriggles free!"))
		captor.dropItemToGround(src)
	released_mob.forceMove(drop_location())
	released_mob.reset_perspective()
	released_mob.setDir(SOUTH)
	if(display_messages)
		released_mob.visible_message(span_warning("[released_mob] uncurls!"))
	if(!QDELETED(src))
		qdel(src)
	return TRUE

/obj/item/mob_holder/relaymove(mob/living/user, direction)
	release()

/obj/item/mob_holder/container_resist()
	release()

/obj/item/mob_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(held_mob == gone)
		release()

/obj/item/mob_holder/on_found(mob/finder)
	if(held_mob?.will_escape_storage())
		to_chat(finder, span_warning("\A [held_mob.name] pops out! "))
		finder.visible_message(span_warning("\A [held_mob.name] pops out of the container [finder] is opening!"), ignored_mobs = finder)
		release(display_messages = FALSE)
		return

/obj/item/mob_holder/drone/Initialize(mapload, mob/living/held_mob, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	//If we're not being put onto a drone, end it all
	if(!isdrone(held_mob))
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/item/mob_holder/drone/insert_mob(mob/living/new_prisoner)
	. = ..()
	if(!isdrone(new_prisoner))
		qdel(src)
		return
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball!"

/obj/item/mob_holder/drone/update_visuals(mob/living/contained)
	var/mob/living/simple_animal/drone/drone = contained
	if(!drone)
		return ..()
	icon = 'icons/mob/drone.dmi'
	icon_state = "[drone.visualAppearance]_hat"

/obj/item/mob_holder/rabbit

/obj/item/mob_holder/rabbit/Initialize(mapload, mob/living/held_mob, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	var/mob/living/simple_animal/rabbit/rabbit = new(src)
	return ..(mapload, rabbit, rabbit.held_state, rabbit.head_icon, rabbit.held_lh, rabbit.held_rh, rabbit.worn_slot_flags)

/obj/item/mob_holder/destructible

/obj/item/mob_holder/destructible/Destroy()
	if(held_mob)
		release(display_messages = TRUE, delete_mob = TRUE)
	return ..()

/obj/item/mob_holder/destructible/release(display_messages = TRUE, delete_mob = FALSE)
	if(delete_mob && held_mob)
		QDEL_NULL(held_mob)
	return ..()

