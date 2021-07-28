//gravitokinetic
/mob/living/simple_animal/hostile/guardian/gravitokinetic
	melee_damage = 15
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = span_holoparasite("As a <b>gravitokinetic</b> type, you can alt click to make the gravity on the ground stronger, and punching applies this effect to a target.")
	magic_fluff_string = span_holoparasite("..And draw the Singularity, an anomalous force of terror.")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Gravitokinetic modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! Caught one! It's a gravitokinetic carp! Now do you understand the gravity of the situation?")
	hive_fluff_string = span_holoparasite("The mass seems to be extremely heavy, and able to relay the heaviness to others.")
	var/list/gravito_targets = list()
	var/gravity_power_range = 10 //how close the stand must stay to the target to keep the heavy gravity
	var/datum/callback/distance_check

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Initialize()
	. = ..()
	distance_check = CALLBACK(src, .proc/__distance_check)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AttackingTarget()
	. = ..()
	if(isliving(target) && target != src)
		to_chat(src, "[span_danger("<B>Your punch has applied heavy gravity to [target]!")]</B>")
		add_gravity(target, 2)
		to_chat(target, span_userdanger("Everything feels really heavy!"))

/mob/living/simple_animal/hostile/guardian/gravitokinetic/AltClickOn(atom/A)
	if(isopenturf(A) && is_deployed() && stat != DEAD && in_range(src, A) && !incapacitated())
		var/turf/T = A
		if(isspaceturf(T))
			to_chat(src, span_warning("You cannot add gravity to space!"))
			return
		visible_message(span_danger("[src] slams their fist into the [T]!"), span_notice("You modify the gravity of the [T]."))
		do_attack_animation(T)
		add_gravity(T, 4)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Recall(forced)
	. = ..()
	to_chat(src, "[span_danger("<B>You have released your gravitokinetic powers!")]</B>")
	for(var/datum/component/C in gravito_targets)
		remove_gravity(C)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/Moved(oldLoc, dir)
	. = ..()
	for(var/datum/component/C in gravito_targets)
		if(get_dist(src, C.parent) > gravity_power_range)
			remove_gravity(C)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/add_gravity(atom/A, new_gravity = 2)
    var/datum/component/C = A.AddComponent(/datum/component/forced_gravity,new_gravity)
    RegisterSignal(A, COMSIG_MOVABLE_MOVED, distance_check)
    gravito_targets.Add(C)
    playsound(src, 'sound/effects/gravhit.ogg', 100, 1)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/remove_gravity(datum/component/C)
	UnregisterSignal(C.parent, COMSIG_MOVABLE_MOVED)
	gravito_targets.Remove(C)
	qdel(C)

/mob/living/simple_animal/hostile/guardian/gravitokinetic/proc/__distance_check(atom/movable/AM, OldLoc, Dir, Forced)
	SIGNAL_HANDLER

	if(get_dist(src, AM) > gravity_power_range)
		remove_gravity(AM.GetComponent(/datum/component/forced_gravity))
