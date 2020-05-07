/datum/guardian_ability/major/gravity
	name = "Gravity"
	desc = "The guardian's punches apply heavy gravity to whatever it punches."
	ui_icon = "weight-hanging"
	cost = 3
	var/list/gravito_targets = list()

/datum/guardian_ability/major/gravity/Apply()
	RegisterSignal(guardian, COMSIG_MOVABLE_MOVED, .proc/recheck_distances)

/datum/guardian_ability/major/gravity/Remove()
	UnregisterSignal(guardian, COMSIG_MOVABLE_MOVED)

/datum/guardian_ability/major/gravity/Attack(atom/target)
	if(isliving(target) && target != guardian)
		to_chat(guardian, "<span class='danger'><B>Your punch has applied heavy gravity to [target]!</span></B>")
		add_gravity(target, 2)
		to_chat(target, "<span class='userdanger'>Everything feels really heavy!</span>")

/datum/guardian_ability/major/gravity/Recall()
	for(var/datum/component/C in gravito_targets)
		if(get_dist(src, C.parent) > (master_stats.potential * 2))
			remove_gravity(C)

/datum/guardian_ability/major/gravity/proc/recheck_distances()
	for(var/datum/component/C in gravito_targets)
		if(get_dist(src, C.parent) > (master_stats.potential * 2))
			remove_gravity(C)

/datum/guardian_ability/major/gravity/AltClickOn(atom/A)
	if(isopenturf(A) && guardian.is_deployed() && guardian.stat != DEAD && in_range(guardian, A) && !guardian.incapacitated())
		var/turf/T = A
		if(isspaceturf(T))
			to_chat(guardian, "<span class='warning'>You cannot add gravity to space!</span>")
			return
		guardian.visible_message("<span class='danger'>[src] slams their fist into the [T]!</span>", "<span class='notice'>You modify the gravity of the [T].</span>")
		guardian.do_attack_animation(T)
		add_gravity(T, 4)

/datum/guardian_ability/major/gravity/proc/add_gravity(atom/A, new_gravity = 2)
    var/datum/component/C = A.AddComponent(/datum/component/forced_gravity,new_gravity)
    RegisterSignal(A, COMSIG_MOVABLE_MOVED, .proc/__distance_check)
    gravito_targets.Add(C)
    playsound(src, 'sound/effects/gravhit.ogg', 100, 1)

/datum/guardian_ability/major/gravity/proc/remove_gravity(datum/component/C)
	UnregisterSignal(C.parent, COMSIG_MOVABLE_MOVED)
	gravito_targets.Remove(C)
	qdel(C)

/datum/guardian_ability/major/gravity/proc/__distance_check(atom/movable/AM, OldLoc, Dir, Forced)
	if(get_dist(src, AM) > (master_stats.potential * 2))
		remove_gravity(AM.GetComponent(/datum/component/forced_gravity))
