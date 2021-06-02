/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "Graffiti. Damn kids."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	gender = NEUTER
	plane = GAME_PLANE //makes the graffiti visible over a wall.
	mergeable_decal = FALSE
	var/do_icon_rotate = TRUE
	var/rotation = 0
	var/paint_colour = "#FFFFFF"

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	. = ..()
	if(e_name)
		name = e_name
	desc = "A [name] vandalizing the station."
	if(alt_icon)
		icon = alt_icon
	if(type)
		icon_state = type
	if(graf_rot)
		rotation = graf_rot
	if(rotation && do_icon_rotate)
		var/matrix/M = matrix()
		M.Turn(rotation)
		src.transform = M
	if(main)
		paint_colour = main
	add_atom_colour(paint_colour, FIXED_COLOUR_PRIORITY)

	if(type == "poseur tag")
		var/datum/team/gang/gang = pick(subtypesof(/datum/team/gang))
		var/gangname = initial(gang.name)
		icon = 'icons/effects/crayondecal.dmi'
		icon_state = "[gangname]"

/obj/effect/decal/cleanable/crayon/NeverShouldHaveComeHere(turf/T)
	return isgroundlessturf(T)


/obj/effect/decal/cleanable/crayon/gang
	icon = 'icons/effects/crayondecal.dmi'
	layer = ABOVE_NORMAL_TURF_LAYER //Harder to hide
	plane = GAME_PLANE
	do_icon_rotate = FALSE //These are designed to always face south, so no rotation please.
	var/datum/team/gang/gang

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, datum/team/gang/G, e_name = "gang tag", rotation = 0,  mob/user)
	if(!G)
		qdel(src)
		return
	gang = G
	var/newcolor = G.color
	var/area/territory = get_area(src)
	icon_state = G.name
	G.new_territories |= list(territory.type = territory.name)
	//If this isn't tagged by a specific gangster there's no bonus income.
	..(mapload, newcolor, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	if(gang)
		var/area/territory = get_area(src)
		gang.territories -= territory.type
		gang.new_territories -= territory.type
		gang.lost_territories |= list(territory.type = territory.name)
	return ..() 
