
/obj/effect/decal/cleanable/gang
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = ABOVE_NORMAL_TURF_LAYER //Harder to hide
	plane = GAME_PLANE
	gender = NEUTER
	var/datum/team/gang/gang

/obj/effect/decal/cleanable/gang/Initialize(mapload, datum/team/gang/G, e_name = "gang tag", rotation = 0,  mob/user)
	if(!G)
		qdel(src)
		return
	gang = G
	name = e_name
	desc = "A [name] vandalizing the station."
	icon_state = G.name
	add_atom_colour(G.color, FIXED_COLOUR_PRIORITY)
	var/area/territory = get_area(src)
	G.territories |= list(territory.type = territory.name)

/obj/effect/decal/cleanable/gang/Destroy()
	if(gang)
		var/area/territory = get_area(src)
		gang.territories -= territory.type
		gang.queued_reputation -= 6
		gang = null
	return ..()
