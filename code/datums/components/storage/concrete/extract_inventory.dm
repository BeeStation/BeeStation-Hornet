/datum/component/storage/concrete/extract_inventory
	max_combined_w_class = WEIGHT_CLASS_TINY * 3
	max_items = 3
	insert_preposition = "in"
//These need to be false in order for the extract's food to be unextractable
//from the inventory
	attack_hand_interact = FALSE
	quickdraw = FALSE
	can_transfer = FALSE
	drop_all_on_deconstruct = FALSE
	locked = TRUE //True in order to prevent messing with the inventory in any way other than the specified ways on reproductive.dm
	rustle_sound = FALSE
	silent = TRUE
	var/obj/item/slimecross/reproductive/parent_slime_extract

/datum/component/storage/concrete/extract_inventory/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/slimecross/reproductive))
		return COMPONENT_INCOMPATIBLE
	parent_slime_extract = parent


/datum/component/storage/concrete/extract_inventory/proc/process_cubes(obj/item/slimecross/reproductive/parent_slime_extract, mob/user)

	if(length(parent_slime_extract.contents) >= max_items)
		QDEL_LIST(parent_slime_extract.contents)
		create_extracts(parent_slime_extract,user)

/datum/component/storage/concrete/extract_inventory/proc/create_extracts(obj/item/slimecross/reproductive/parent_slime_extract, mob/user)
	var/cores = rand(1,4)
	playsound(parent_slime_extract, 'sound/effects/splat.ogg', 40, TRUE)
	parent_slime_extract.last_produce = world.time
	to_chat(user, "<span class='notice'>[parent_slime_extract] briefly swells to a massive size, and expels [cores] extract[cores > 1 ? "s":""]!</span>")
	for(var/i in 1 to cores)
		new parent_slime_extract.extract_type(parent_slime_extract.drop_location())
