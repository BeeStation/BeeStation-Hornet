/mob/living/basic/pet
	icon = 'icons/mob/simple/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	blood_volume = BLOOD_VOLUME_NORMAL

	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE
	/// If the mob has collar sprites, this is the base of the icon states.
	var/collar_icon_state = null
	/// We have a seperate _rest collar icon state when the pet is resting.
	var/has_collar_resting_icon_state = FALSE

	/// Our collar
	var/obj/item/clothing/neck/petcollar/collar

/mob/living/basic/pet/Initialize(mapload)
	. = ..()

	// String assoc list returns a cached list, so this is like a static list to pass into the element below.
	var/static/list/habitable_atmos = list(
		"min_oxy" = 5,
		"max_oxy" = 0,
		"min_plas" = 0,
		"max_plas" = 1,
		"min_co2" = 0,
		"max_co2" = 5,
		"min_n2" = 0,
		"max_n2" = 0,
	)

	AddElement(/datum/element/atmos_requirements, atmos_requirements = habitable_atmos, unsuitable_atmos_damage = 1)
	AddElement(/datum/element/basic_body_temp_sensitive)

	/// Can set the collar var beforehand to start the pet with a collar.
	if(collar)
		collar = new(src)

	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/pet/Destroy()
	. = ..()

	QDEL_NULL(collar)

/mob/living/basic/pet/attackby(obj/item/thing, mob/user, params)
	if(istype(thing, /obj/item/clothing/neck/petcollar) && !collar)
		add_collar(thing, user)
		return TRUE

	if(istype(thing, /obj/item/newspaper) && !stat)
		user.visible_message(span_notice("[user] baps [name] on the nose with the rolled up [thing]."))
		dance_rotate(src)
		return TRUE

	return ..()

/mob/living/basic/pet/update_overlays()
	. = ..()

	if(!collar || !collar_icon_state)
		return

	// Determine which status tag to add to the middle of the icon state.
	var/dead_tag = stat == DEAD ? "_dead" : null
	var/rest_tag = has_collar_resting_icon_state && resting ? "_rest" : null
	var/stat_tag = dead_tag || rest_tag || ""

	. += mutable_appearance(icon, "[collar_icon_state][stat_tag]collar")
	. += mutable_appearance(icon, "[collar_icon_state][stat_tag]tag")

/mob/living/basic/pet/gib()
	. = ..()

	remove_collar(drop_location(), update_visuals = FALSE)

/mob/living/basic/pet/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/pet/death(gibbed)
	. = ..()
	add_memory_in_range(src, 7, MEMORY_PET_DEAD, list(DETAIL_DEUTERAGONIST = src), story_value = STORY_VALUE_AMAZING, memory_flags = MEMORY_CHECK_BLIND_AND_DEAF) //Protagonist is the person memorizing it

/mob/living/basic/pet/handle_atom_del(atom/deleting_atom)
	. = ..()

	if(deleting_atom != collar)
		return

	collar = null

	if(QDELETED(src))
		return

	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/pet/update_stat()
	. = ..()

	update_icon(UPDATE_OVERLAYS)

/mob/living/basic/pet/set_resting(new_resting, silent, instant)
	. = ..()

	if(!has_collar_resting_icon_state)
		return

	update_icon(UPDATE_OVERLAYS)

/**
 * Add a collar to the pet.
 *
 * Arguments:
 * * new_collar - the collar.
 * * user - the user that did it.
 */
/mob/living/basic/pet/proc/add_collar(obj/item/clothing/neck/petcollar/new_collar, mob/user)
	if(QDELETED(new_collar) || collar)
		return
	if(!user.transferItemToLoc(new_collar, src))
		return

	collar = new_collar
	if(collar_icon_state)
		update_icon(UPDATE_OVERLAYS)

	to_chat(user, span_notice("You put [new_collar] around [src]'s neck."))
	if(new_collar.tagname && !unique_pet)
		fully_replace_character_name(null, "\proper [new_collar.tagname]")

/**
 * Remove the collar from the pet.
 */
/mob/living/basic/pet/proc/remove_collar(atom/new_loc, update_visuals = TRUE)
	if(!collar)
		return

	var/obj/old_collar = collar

	collar.forceMove(new_loc)
	collar = null

	if(collar_icon_state && update_visuals)
		update_icon(UPDATE_OVERLAYS)

	return old_collar
