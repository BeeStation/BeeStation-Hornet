/obj/vehicle/sealed/car
	layer = ABOVE_MOB_LAYER
	move_resist = MOVE_FORCE_VERY_STRONG
	///Bitflags for special behavior such as kidnapping
	var/car_traits = NONE
	///Sound file(s) to play when we drive around
	var/engine_sound = 'sound/vehicles/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 2 SECONDS //Set this to the length of the engine sound
	var/escape_time = 6 SECONDS //Time it takes to break out of the car
	/// How long it takes to move, cars don't use the riding component similar to mechs so we handle it ourselves
	var/vehicle_move_delay = 1
	/// How long it takes to rev (vrrm vrrm!)
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/sealed/car/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/dump_kidnapped_mobs, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/proc/RunOver(mob/living/carbon/human/H) //pasted right out of mulebot code
	log_combat(src, H, "run over", null, "(DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message(span_danger("[src] drives over [H]!"), \
					span_userdanger("[src] drives over you!"))
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = 10
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD)
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST)
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG)
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG)
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM)
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM)

	var/turf/T = get_turf(src)
	T.add_mob_blood(H)

/obj/vehicle/sealed/car/MouseDrop_T(atom/dropping, mob/M)
	if(M.stat != CONSCIOUS || HAS_TRAIT(M, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((car_traits & CAN_KIDNAP) && isliving(dropping) && M != dropping)
		var/mob/living/L = dropping
		L.visible_message(span_warning("[M] starts forcing [L] into [src]!"))
		mob_try_forced_enter(M, L)
	return ..()

/obj/vehicle/sealed/car/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M != user || !(LAZYACCESS(occupants, M) & VEHICLE_CONTROL_KIDNAPPED))
		mob_exit(M, silent)
		return TRUE
	to_chat(user, "<span class='notice'>You push against the back of \the [src]'s trunk to try and get out.</span>")
	if(!do_after(user, escape_time, target = src))
		return FALSE
	to_chat(user,"<span class='danger'>[user] gets out of [src].</span>")
	mob_exit(M, silent)
	return TRUE

/obj/vehicle/sealed/car/attack_hand(mob/living/user)
	. = ..()
	if(!(car_traits & CAN_KIDNAP))
		return
	to_chat(user, "<span class='notice'>You start opening [src]'s trunk.</span>")
	if(!do_after(user, 30))
		return
	if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, "<span class='notice'>The people stuck in [src]'s trunk all come tumbling out.</span>")
		dump_specific_mobs(VEHICLE_CONTROL_KIDNAPPED)
		return
	to_chat(user, "<span class='notice'>It seems [src]'s trunk was empty.</span>")

///attempts to force a mob into the car
/obj/vehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/kidnapped, silent = FALSE)
	if(occupant_amount() >= max_occupants)
		return FALSE
	var/atom/old_loc = loc
	if(do_after(forcer, get_enter_delay(kidnapped), kidnapped, extra_checks=CALLBACK(src, TYPE_PROC_REF(/obj/vehicle/sealed/car, is_car_stationary), old_loc)))
		mob_forced_enter(kidnapped, silent)
		return TRUE
	return FALSE

///Callback proc to check for
/obj/vehicle/sealed/car/proc/is_car_stationary(atom/old_loc)
	return (old_loc == loc)

/obj/vehicle/sealed/car/proc/mob_forced_enter(mob/kidnapped, silent = FALSE)
	if(!silent)
		kidnapped.visible_message(span_warning("[kidnapped] is forced into \the [src]!"))
	kidnapped.forceMove(src)
	add_occupant(kidnapped, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/atom_destruction(damage_flag)
	explosion(loc, 0, 1, 2, 3, 0)
	log_message("[src] exploded due to destruction", LOG_ATTACK)
	return ..()

/obj/vehicle/sealed/car/relaymove(mob/living/user, direction)
	if(canmove && (!key_type || istype(inserted_key, key_type)))
		vehicle_move(direction)
	return TRUE

/obj/vehicle/sealed/car/vehicle_move(direction)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, vehicle_move_delay)

	if(COOLDOWN_FINISHED(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, engine_sound_length)
		playsound(get_turf(src), engine_sound, 100, TRUE)

	if(trailer)
		var/dir_to_move = get_dir(trailer.loc, loc)
		var/did_move = step(src, direction)
		if(did_move)
			step(trailer, dir_to_move)
		return did_move
	after_move(direction)
	return step(src, direction)
