/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.stat)
			return L
		else
			enemies -= L
	else if(ismecha(A))
		var/obj/mecha/M = A
		if(M.occupant)
			return A

/mob/living/simple_animal/hostile/retaliate/ListTargets()
	if(!enemies.len)
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see

/mob/living/simple_animal/hostile/retaliate/proc/Retaliate()
	for(var/atom/movable/A as obj|mob in oview(vision_range, src))
		if(isliving(A))
			var/mob/living/M = A
			if(attack_same || !faction_check_mob(M))
				enemies |= M
			if(istype(M, /mob/living/simple_animal/hostile/retaliate))
				var/mob/living/simple_animal/hostile/retaliate/H = M
				if(attack_same && H.attack_same)
					H.enemies |= enemies
		else if(ismecha(A))
			var/obj/mecha/M = A
			if(M.occupant)
				enemies |= M
				enemies |= M.occupant
	return FALSE

/mob/living/simple_animal/hostile/retaliate/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && stat == CONSCIOUS)
		Retaliate()
