
/obj/effect/decal/gang
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = ABOVE_NORMAL_TURF_LAYER //Harder to hide
	plane = GAME_PLANE
	gender = NEUTER
	var/datum/team/gang/gang

/obj/effect/decal/gang/Initialize(mapload, datum/team/gang/G, e_name = "gang tag", rotation = 0,  mob/user)
	if(!G)
		qdel(src)
		return
	gang = G
	var/area/territory = get_area(src)
	G.new_territories |= list(territory.type = territory.name)

	name = e_name
	desc = "A [name] vandalizing the station."
	icon_state = G.name
	add_atom_colour(G.color, FIXED_COLOUR_PRIORITY)


/obj/effect/decal/gang/Destroy()
	if(gang)
		var/area/territory = get_area(src)
		gang.territories -= territory.type
		gang.new_territories -= territory.type
		gang.lost_territories |= list(territory.type = territory.name)
	return ..()
