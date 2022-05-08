/obj/item/grenade/antigravity
	name = "antigravity grenade"
	icon_state = "emp"
	item_state = "emp"

	var/range = 7
	var/forced_value = 0
	var/duration = 300

/obj/item/grenade/antigravity/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	update_mob()

	for(var/turf/T in view(range,src))
		T.AddElement(/datum/element/forced_gravity, forced_value)
		addtimer(CALLBACK(T, /datum/.proc/_RemoveElement, list(/datum/element/forced_gravity, forced_value)), duration) //we can't use the macro define here because this needs an actual proc

	qdel(src)
