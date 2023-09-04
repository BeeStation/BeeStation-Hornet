/datum/guardian_ability/major/gravity
	name = "Gravity"
	desc = "The guardian's punches apply heavy gravity to whatever it punches."
	ui_icon = "weight-hanging"
	cost = 3
	var/list/gravito_targets = list()

/datum/guardian_ability/major/gravity/Apply()
	RegisterSignal(guardian, COMSIG_MOVABLE_MOVED, PROC_REF(recheck_distances))

/datum/guardian_ability/major/gravity/Remove()
	UnregisterSignal(guardian, COMSIG_MOVABLE_MOVED)

/datum/guardian_ability/major/gravity/Attack(atom/target)
	if(isliving(target) && target != guardian)
		to_chat(guardian, "<span class='danger'><B>Your punch has applied heavy gravity to [target]!</span></B>")
		add_gravity(target, 2)
		to_chat(target, "<span class='userdanger'>Everything feels really heavy!</span>")

/datum/guardian_ability/major/gravity/Recall()
	for(var/i in gravito_targets)
		if(get_dist(src, i) > (master_stats.potential * 2))
			remove_gravity(i)

/datum/guardian_ability/major/gravity/proc/recheck_distances()
	SIGNAL_HANDLER

	for(var/i in gravito_targets)
		if(get_dist(src, i) > (master_stats.potential * 2))
			remove_gravity(i)

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
	RegisterSignal(A, COMSIG_MOVABLE_MOVED, PROC_REF(__distance_check))
	A.AddElement(/datum/element/forced_gravity, new_gravity)
	gravito_targets[A] = new_gravity
	playsound(src, 'sound/effects/gravhit.ogg', 100, TRUE)

/datum/guardian_ability/major/gravity/proc/remove_gravity(atom/target)
	if(isnull(gravito_targets[target]))
		return
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/forced_gravity, gravito_targets[target])
	gravito_targets -= target

/datum/guardian_ability/major/gravity/proc/__distance_check(atom/movable/AM, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(get_dist(src, AM) > (master_stats.potential * 2))
		remove_gravity(AM)
