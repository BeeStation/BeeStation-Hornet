
GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/binary/dp_vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(atom/A)
	if(!ventcrawler || !Adjacent(A))
		return
	if(stat)
		to_chat(src, "You must be conscious to do this!")
		return
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		to_chat(src, span_warning("You can't move into the vent!"))
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		to_chat(src, span_warning("You need to be able to use your hands to ventcrawl!"))
		return
	if(has_buckled_mobs())
		to_chat(src, "You can't vent crawl with other creatures on you!")
		return
	if(buckled)
		to_chat(src, "You can't vent crawl while buckled!")
		return

	var/obj/machinery/atmospherics/components/vent_found


	if(A)
		vent_found = A
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null

	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1,src))
			if(!is_type_in_typecache(machine, GLOB.ventcrawl_machinery))
				continue
			vent_found = machine

			if(!vent_found.can_crawl_through())
				vent_found = null

			if(vent_found)
				break


	if(vent_found)
		var/datum/pipenet/vent_found_parent = vent_found.parents[1]
		if(vent_found_parent && (vent_found_parent.members.len || vent_found_parent.other_atmos_machines))
			visible_message(span_notice("[src] begins climbing into the ventilation system.") ,span_notice("You begin climbing into the ventilation system."))

			ADD_TRAIT(src, TRAIT_NO_MOVE_PULL, VENTCRAWLING_TRAIT)
			ADD_TRAIT(src, TRAIT_NOMOBSWAP, VENTCRAWLING_TRAIT)
			ADD_TRAIT(src, TRAIT_PUSHIMMUNE, VENTCRAWLING_TRAIT)
			if(!do_after(src, 25, target = vent_found))
				REMOVE_TRAIT(src, TRAIT_NO_MOVE_PULL, VENTCRAWLING_TRAIT)
				REMOVE_TRAIT(src, TRAIT_NOMOBSWAP, VENTCRAWLING_TRAIT)
				REMOVE_TRAIT(src, TRAIT_PUSHIMMUNE, VENTCRAWLING_TRAIT)
				return
			REMOVE_TRAIT(src, TRAIT_NO_MOVE_PULL, VENTCRAWLING_TRAIT)
			REMOVE_TRAIT(src, TRAIT_NOMOBSWAP, VENTCRAWLING_TRAIT)
			REMOVE_TRAIT(src, TRAIT_PUSHIMMUNE, VENTCRAWLING_TRAIT)

			if(!client)
				return

			if(iscarbon(src) && ventcrawler < 2)//It must have atleast been 1 to get this far
				var/failed = 0
				var/list/items_list = get_equipped_items(include_pockets = TRUE)
				if(items_list.len)
					failed = 1
				for(var/obj/item/I in held_items)
					failed = 1
					break
				if(failed)
					to_chat(src, span_warning("You can't crawl around in the ventilation ducts with items!"))
					return

			visible_message(span_notice("[src] scrambles into the ventilation ducts!"),span_notice("You climb into the ventilation ducts."))
			forceMove(vent_found)
	else
		to_chat(src, span_warning("This ventilation duct is not connected to anything!"))

/mob/living/simple_animal/slime/handle_ventcrawl(atom/A)
	if(buckled)
		to_chat(src, "<i>I can't vent crawl while feeding...</i>")
		return
	..()


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	if(!istype(starting_machine) || !starting_machine.can_see_pipes())
		return
	var/list/totalMembers = list()

	for(var/datum/pipenet/P in starting_machine.return_pipenets())
		totalMembers += P.members
		totalMembers += P.other_atmos_machines

	if(!totalMembers.len)
		return

	if(client)
		for(var/X in totalMembers)
			var/obj/machinery/atmospherics/A = X //all elements in totalMembers are necessarily of this type.
			if(in_view_range(client.mob, A))
				if(!A.pipe_vision_img)
					A.pipe_vision_img = image(A, A.loc, dir = A.dir)
					A.pipe_vision_img.plane = ABOVE_HUD_PLANE
				client.images += A.pipe_vision_img
				pipes_shown += A.pipe_vision_img
	ADD_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)


/mob/living/proc/remove_ventcrawl()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
	pipes_shown.len = 0
	REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)




//OOP
/atom/proc/update_pipe_vision(atom/new_loc = null)
	return

/mob/living/update_pipe_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_ventcrawl()
	add_ventcrawl(.)

