/obj/vehicle/ridden
	name = "ridden vehicle"
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = FALSE
	default_driver_move = FALSE
	pass_flags_self = PASSTABLE
	var/rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS
	COOLDOWN_DECLARE(message_cooldown)

/obj/vehicle/ridden/Initialize(mapload)
	. = ..()
	LoadComponent(/datum/component/riding)

/obj/vehicle/ridden/examine(mob/user)
	. = ..()
	if(key_type)
		if(!inserted_key)
			. += "<span class='notice'>Put a key inside it by clicking it with the key.</span>"
		else
			. += "<span class='notice'>Alt-click [src] to remove the key.</span>"

/obj/vehicle/ridden/generate_action_type(actiontype)
	var/datum/action/vehicle/ridden/A = ..()
	. = A
	if(istype(A))
		A.vehicle_ridden_target = src

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	return ..()

/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/vehicle/ridden/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")
			if(inserted_key)	//just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, "<span class='notice'>[I] seems to be stuck to your hand!</span>")
		return
	return ..()

/obj/vehicle/ridden/AltClick(mob/user)
	if(inserted_key && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(!is_occupant(user))
			to_chat(user, "<span class='notice'>You must be riding the [src] to remove [src]'s key!</span>")
			return
		to_chat(user, "<span class='notice'>You remove \the [inserted_key] from \the [src].</span>")
		inserted_key.forceMove(drop_location())
		user.put_in_hands(inserted_key)
		inserted_key = null
	return

/obj/vehicle/ridden/driver_move(mob/living/user, direction)
	if(key_type && !is_key(inserted_key))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>[src] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return FALSE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate \the [src] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return FALSE

	if(rider_check_flags & REQUIRES_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [src].</span>",\
			"<span class='danger'>You fall off \the [src] while trying to operate it while unable to stand!</span>")
			if(isliving(user))
				var/mob/living/L = user
				L.Stun(3 SECONDS)
			return FALSE
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move \the [src]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return FALSE

	if(rider_check_flags & REQUIRES_ARMS && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [src].</span>",\
			"<span class='danger'>You fall off \the [src] while trying to operate it without being able to hold on!</span>")
			if(isliving(user))
				var/mob/living/rider = user
				rider.Stun(3 SECONDS)
			return FALSE

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that unable to hold onto \the [src] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return FALSE

	var/datum/component/riding/R = GetComponent(/datum/component/riding)
	R.handle_ride(user, direction)
	return ..()

/obj/vehicle/ridden/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	. = ..(M, user, FALSE)

/obj/vehicle/ridden/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force && occupant_amount() >= max_occupants)
		return FALSE
	return ..()

/obj/vehicle/ridden/onZImpact(turf/newloc, levels)
	if(levels > 1)
		for(var/mob/M in occupants)
			unbuckle_mob(M) // Even though unbuckle_all_mobs exists we may as well only iterate once
			M.onZImpact(newloc, levels)

/obj/vehicle/ridden/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()

	if(mover.pass_flags & PASSTABLE)
		return TRUE
