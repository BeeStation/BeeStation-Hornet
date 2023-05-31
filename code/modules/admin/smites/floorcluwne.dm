/// Spawns the evil floor cluwne to terrorize people
/datum/smite/floorcluwne
	name = "Spawn Floor Cluwne"

/datum/smite/floorcluwne/effect(client/user, mob/living/target)
	. = ..()
	if(!ishuman(target))
		to_chat(usr,"<span class='warning'>You may only floorcluwne humans!</span>")
		return

	var/turf/T = get_turf(target)
	var/mob/living/simple_animal/hostile/floor_cluwne/FC = new(T)
	FC.invalid_area_typecache = list()  // works anywhere
	FC.delete_after_target_killed = TRUE
	FC.force_target(target)
	FC.stage = 4
