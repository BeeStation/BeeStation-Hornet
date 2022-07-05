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
		if(GLOB.total_slimes >= CONFIG_GET(number/max_slimes))
			to_chat(user, "<span class='warning'>The extract jiggles, and fails to produce a slime...</span>")
			return
		create_extracts(parent_slime_extract,user)

/datum/component/storage/concrete/extract_inventory/proc/create_extracts(obj/item/slimecross/reproductive/parent_slime_extract, mob/user)
	playsound(parent_slime_extract, 'sound/effects/splat.ogg', 40, TRUE)
	parent_slime_extract.last_produce = world.time
	to_chat(user, "<span class='notice'>[parent_slime_extract] briefly swells to a massive size, and expels a baby slime!</span>")
	new /mob/living/simple_animal/slime(parent_slime_extract.drop_location(), parent_slime_extract.colour)
