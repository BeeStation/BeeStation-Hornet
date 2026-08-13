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

	if(parent_slime_extract.contents.len >= max_slots)
		QDEL_LIST(parent_slime_extract.contents)
		createExtracts(user)

/datum/storage/extract_inventory/proc/createExtracts(mob/user)
	var/obj/item/slimecross/reproductive/parent_slime_extract = parent?.resolve()
	if(!parent_slime_extract)
		return

	var/cores = rand(1,4)
	playsound(parent_slime_extract, 'sound/effects/splat.ogg', 40, TRUE)
	parent_slime_extract.last_produce = world.time
	to_chat(user, span_notice("[parent_slime_extract] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!"))
	for(var/i in 1 to cores)
		new parent_slime_extract.extract_type(parent_slime_extract.drop_location())
