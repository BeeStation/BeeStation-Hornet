/// Spawns the evil floor cluwne to terrorize people
/datum/smite/floorcluwne
	name = "Floor Cluwne (Aggressive)"

/datum/smite/floorcluwne/effect(client/user, mob/living/target)
	. = ..()
	if(!ishuman(target))
		to_chat(usr,span_warning("You may only floorcluwne humans!"))
		return

	var/turf/T = get_turf(target)
	var/mob/living/simple_animal/hostile/floor_cluwne/FC = new(T)
	FC.invalid_area_typecache = list()  // works anywhere
	FC.delete_after_target_killed = TRUE
	FC.force_target(target)
	FC.stage = 4
