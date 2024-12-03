/datum/storage/extract_inventory
	max_total_storage = WEIGHT_CLASS_TINY * 3
	max_slots = 3
	insert_preposition = "in"
	attack_hand_interact = FALSE
	quickdraw = FALSE
	locked = TRUE
	rustle_sound = FALSE
	silent = TRUE

/datum/storage/extract_inventory/New()
	. = ..()
	set_holdable(/obj/item/food/monkeycube)

	var/obj/item/slimecross/reproductive/parent_slime_extract = parent?.resolve()
	if(!parent_slime_extract)
		return

	if(!istype(parent_slime_extract, /obj/item/slimecross/reproductive))
		stack_trace("storage subtype extract_inventory incompatible with [parent_slime_extract]")
		qdel(src)

/datum/storage/extract_inventory/proc/process_cubes(mob/user)
	var/obj/item/slimecross/reproductive/parent_slime_extract = parent?.resolve()
	if(!parent_slime_extract)
		return

	message_admins(parent_slime_extract.contents.len)
	if(parent_slime_extract.contents.len >= max_slots)
		QDEL_LIST(parent_slime_extract.contents)
		if(GLOB.total_slimes >= CONFIG_GET(number/max_slimes))
			to_chat(user, "<span class='warning'>The extract jiggles, and fails to produce a slime...</span>")
			return
		createExtracts(user)

/datum/storage/extract_inventory/proc/createExtracts(mob/user)
	var/obj/item/slimecross/reproductive/parent_slime_extract = parent?.resolve()
	if(!parent_slime_extract)
		return

	playsound(parent_slime_extract, 'sound/effects/splat.ogg', 40, TRUE)
	parent_slime_extract.last_produce = world.time
	to_chat(user, "<span class='notice'>[parent_slime_extract] briefly swells to a massive size, and expels a baby slime!</span>")
	new /mob/living/simple_animal/slime(parent_slime_extract.drop_location(), parent_slime_extract.colour)
