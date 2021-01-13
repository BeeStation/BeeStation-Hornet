/datum/guardian_ability/major/hand
	name = "The Hand"
	desc = "The guardian can use it's hand(s) to erase the space in front of it, bring any desired target closer."
	ui_icon = "hand-lizard"
	cost = 5
	var/next_hand = 0

/datum/guardian_ability/major/hand/RangedAttack(atom/target)
	if(world.time < next_hand || guardian.Adjacent(target) || !isturf(guardian.loc) || !guardian.is_deployed())
		return ..()
	playsound(guardian, 'sound/magic/blink.ogg', 100, TRUE) // blink lol
	next_hand = world.time + ((10 / master_stats.potential) * 10)
	var/turf/hand_turf = get_step(guardian, get_dir(guardian, target))
	for(var/atom/movable/AM in get_turf(target))
		if(AM.anchored)
			continue
		AM.forceMove(hand_turf)
	guardian.face_atom(hand_turf)
	return ..()

/datum/guardian_ability/major/hand/Stat()
	. = ..()
	if(statpanel("Status"))
		if(next_hand > world.time)
			stat(null, "THE HAND Cooldown Remaining: [DisplayTimeText(next_hand - world.time)]")
