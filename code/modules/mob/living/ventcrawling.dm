
GLOBAL_LIST_INIT(ventcrawl_machinery, typecacheof(list(
	/obj/machinery/atmospherics/components/binary/dp_vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_pump,
	/obj/machinery/atmospherics/components/unary/vent_scrubber)))

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(atom/A)
	// Being able to always ventcrawl trumps being only able to ventcrawl when wearing nothing
	var/required_nudity = HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS)
	if(!Adjacent(A))
		return
	if(!HAS_TRAIT(src, TRAIT_VENTCRAWLER_NUDE) && !HAS_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS))
		return
	if(stat)
		to_chat(src, "You must be conscious to do this!")
		return
	if(IsStun() || IsParalyzed())
		to_chat(src, "You can't vent crawl while you're stunned!")
		return
	if(restrained())
		to_chat(src, "You can't vent crawl while you're restrained!")
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
		var/datum/pipeline/vent_found_parent = vent_found.parents[1]
		if(vent_found_parent && (vent_found_parent.members.len || vent_found_parent.other_atmosmch))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system.</span>" ,"<span class='notice'>You begin climbing into the ventilation system.</span>")

			if(!do_after(src, 25, target = vent_found))
				return

			if(!client)
				return

			if(iscarbon(src) && required_nudity)
				if(length(get_equipped_items(include_pockets = TRUE)) || get_num_held_items())
					to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
					return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			forceMove(vent_found)
	else
		to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")

/mob/living/simple_animal/slime/handle_ventcrawl(atom/A)
	if(buckled)
		to_chat(src, "<i>I can't vent crawl while feeding...</i>")
		return
	return ..()


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine)
	if(!istype(starting_machine) || !starting_machine.can_see_pipes())
		return
	var/list/totalMembers = list()

	for(var/datum/pipeline/P in starting_machine.returnPipenets())
		totalMembers += P.members
		totalMembers += P.other_atmosmch

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
	setMovetype(movement_type | VENTCRAWLING)


/mob/living/proc/remove_ventcrawl()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
	pipes_shown.len = 0
	setMovetype(movement_type & ~VENTCRAWLING)




//OOP
/atom/proc/update_pipe_vision(atom/new_loc = null)
	return

/mob/living/update_pipe_vision(atom/new_loc = null)
	. = loc
	if(new_loc)
		. = new_loc
	remove_ventcrawl()
	add_ventcrawl(.)

