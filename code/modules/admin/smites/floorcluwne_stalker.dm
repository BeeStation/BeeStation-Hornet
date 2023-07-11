/// Spawns the evil floor cluwne to terrorize people
/datum/smite/floorcluwne_stalker
	name = "Floor Cluwne (Stalker)"

/datum/smite/floorcluwne_stalker/effect(client/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/H = target
	var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(get_turf(target))
	FC.force_target(H)
	FC.delete_after_target_killed = TRUE
