/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)

	if(movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return FALSE
	if((lube & NO_SLIP_ON_CATWALK) && (locate(/obj/structure/lattice/catwalk) in get_turf(src)))
		return FALSE
	if(!(lube & SLIDE_ICE))
		log_combat(src, (O ? O : get_turf(src)), "slipped on the", null, ((lube & SLIDE) ? "(LUBE)" : null))
	return loc.handle_slip(src, knockdown_amount, O, lube, paralyze, force_drop)

/mob/living/carbon/Process_Spacemove(movement_dir = FALSE)
	if(..())
		return TRUE
	if(!isturf(loc))
		return FALSE

	// Do we have a jetpack implant (and is it on)?
	if(has_jetpack_power(movement_dir))
		return TRUE

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()

	if(. && !(movement_type & FLOATING)) //floating is easy
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			set_nutrition(NUTRITION_LEVEL_FED - 1)	//just less than feeling vigorous
		else if(nutrition && stat != DEAD)
			adjust_nutrition(-(HUNGER_FACTOR/10))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(HUNGER_FACTOR/10))

/mob/living/carbon/set_usable_legs(new_value)
	. = ..()
	if(isnull(.))
		return
	if(. == 0)
		if(usable_legs != 0) //From having no usable legs to having some.
			REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_legs == 0 && !(movement_type & (FLYING | FLOATING))) //From having usable legs to no longer having them.
		ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(!usable_hands)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)


/mob/living/carbon/set_usable_hands(new_value)
	. = ..()
	if(isnull(.))
		return
	if(. == 0)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(usable_hands != 0) //From having no usable hands to having some.
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_hands == 0 && default_num_hands > 0) //From having usable hands to no longer having them.
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(!usable_legs && !(movement_type & (FLYING | FLOATING)))
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

/mob/living/carbon/on_movement_type_flag_enabled(datum/source, flag)
	. = ..()
	if(flag & (FLYING | FLOATING) && (movement_type & (FLYING | FLOATING) == flag))
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

/mob/living/carbon/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING | FLOATING) && !(movement_type & (FLYING | FLOATING)))
		var/limbless_slowdown = 0
		if(usable_legs < default_num_legs)
			limbless_slowdown += (default_num_legs - usable_legs) * 3
			if(!usable_legs)
				ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
				if(usable_hands < default_num_hands)
					limbless_slowdown += (default_num_hands - usable_hands) * 3
					if(!usable_hands)
						ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(limbless_slowdown)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = limbless_slowdown)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/limbless)

/mob/living/carbon/proc/start_leaning(obj/wall)

	switch(dir)
		if(SOUTH)
			pixel_y += LEANING_OFFSET
		if(NORTH)
			pixel_y += -LEANING_OFFSET
		if(WEST)
			pixel_x += LEANING_OFFSET
		if(EAST)
			pixel_x += -LEANING_OFFSET

	ADD_TRAIT(src, TRAIT_UNDENSE, LEANING_TRAIT)
	visible_message("<span class='notice'>[src] leans against \the [wall]!</span>", \
						"<span class='notice'>You lean against \the [wall]!</span>")
	RegisterSignals(src, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_START_PULL, COMSIG_ATOM_TELEPORT_ACT, COMSIG_ATOM_DIR_CHANGE), PROC_REF(stop_leaning))
	is_leaning = TRUE

/mob/living/carbon/proc/stop_leaning()
	SIGNAL_HANDLER
	UnregisterSignal(src, list(COMSIG_MOB_CLIENT_PRE_MOVE, COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_START_PULL, COMSIG_ATOM_TELEPORT_ACT, COMSIG_ATOM_DIR_CHANGE))
	is_leaning = FALSE
	pixel_y = base_pixel_y + body_position_pixel_x_offset
	pixel_x = base_pixel_y + body_position_pixel_y_offset
	REMOVE_TRAIT(src, TRAIT_UNDENSE, LEANING_TRAIT)
