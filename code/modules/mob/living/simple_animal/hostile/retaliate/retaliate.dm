/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.stat)
			return L
		else
			remove_enemy(L)
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
				add_enemy(M)
			if(istype(M, /mob/living/simple_animal/hostile/retaliate))
				var/mob/living/simple_animal/hostile/retaliate/H = M
				if(attack_same && H.attack_same)
					H.add_enemies(enemies)
		else if(ismecha(A))
			var/obj/mecha/M = A
			if(M.occupant)
				add_enemy(M)
				add_enemy(M.occupant)
	return FALSE

/mob/living/simple_animal/hostile/retaliate/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && stat == CONSCIOUS)
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/proc/add_enemy(new_enemy)
	RegisterSignal(new_enemy, COMSIG_PARENT_QDELETING, PROC_REF(remove_enemy), override = TRUE)
	enemies |= new_enemy

/mob/living/simple_animal/hostile/retaliate/proc/add_enemies(new_enemies)
	for(var/new_enemy in new_enemies)
		RegisterSignal(new_enemy, COMSIG_PARENT_QDELETING, PROC_REF(remove_enemy), override = TRUE)
		enemies |= new_enemy

/mob/living/simple_animal/hostile/retaliate/proc/clear_enemies()
	for(var/enemy in enemies)
		UnregisterSignal(enemy, COMSIG_PARENT_QDELETING)
	enemies.Cut()

/mob/living/simple_animal/hostile/retaliate/proc/remove_enemy(datum/enemy_to_remove)
	SIGNAL_HANDLER
	UnregisterSignal(enemy_to_remove, COMSIG_PARENT_QDELETING)
	enemies -= enemy_to_remove
	if(enemy_to_remove == target) // if its the same we null the reference in target
		target = null

/mob/living/simple_animal/hostile/retaliate/add_target(new_target)
	if(target && !(target in enemies)) //we should not remove the signal if it still exists in the enemies list
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = new_target
	if(target) //we could also check here again if this is in the enemies list but override = TRUE might be the better idea here
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_enemy), override = TRUE)
