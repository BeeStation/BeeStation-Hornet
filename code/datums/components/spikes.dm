/datum/component/spikes
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/spikedamage = 1
	var/armor = 0
	var/id = null
	var/finalarmor = 0
	var/cooldown = 0

/datum/component/spikes/Initialize(damage = 0, spikearmor = 0, diseaseid = null)
	spikedamage = damage
	armor = spikearmor
	id = diseaseid
	RegisterSignal(parent, COMSIG_MOVABLE_BUMP, PROC_REF(prick_collide))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(prick_crossed))
	RegisterSignal(parent, COMSIG_DISEASE_END, PROC_REF(checkdiseasecure))
	if(ishuman(parent))
		if(armor)
			setarmor(parent)
			RegisterSignal(parent, COMSIG_CARBON_SPECIESCHANGE, PROC_REF(setarmor))
			RegisterSignal(parent, COMSIG_COMPONENT_REMOVING, PROC_REF(removearmor))
		RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, PROC_REF(prick_touch))
		RegisterSignal(parent, COMSIG_MOB_HAND_ATTACKED, PROC_REF(prick_touched))


/datum/component/spikes/proc/prick(mob/living/carbon/C, damage_mod = 1)
	var/netdamage = spikedamage * damage_mod
	if(istype(C) && cooldown <= world.time)
		var/atom/movable/P = parent
		var/def_check = C.getarmor(type = "melee")
		C.apply_damage(netdamage, BRUTE, blocked = def_check)
		P.visible_message("<span class='warning'>[C.name] is pricked on [P.name]'s spikes.</span>")
		playsound(get_turf(P), 'sound/weapons/slice.ogg', 50, 1)
		cooldown = (world.time + 8) //spike cooldown is equal to default unarmed attack speed

/datum/component/spikes/proc/prick_touch(datum/source, mob/living/carbon/human/M, mob/living/carbon/human/H)
	SIGNAL_HANDLER

	prick(H, 0.5)

/datum/component/spikes/proc/prick_touched(datum/source, mob/living/carbon/human/H, mob/living/carbon/human/M)
	SIGNAL_HANDLER

	prick(M, 1.5)

/datum/component/spikes/proc/prick_collide(datum/source, atom/A)
	SIGNAL_HANDLER

	if(iscarbon(A))
		var/mob/living/carbon/C = A
		prick(C)

/datum/component/spikes/proc/prick_crossed(datum/source, atom/movable/M)
	SIGNAL_HANDLER

	var/atom/movable/P = parent
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))
			if((H.movement_type & FLYING) || !(H.mobility_flags & MOBILITY_STAND)|| H.buckled || H.shoes || feetCover)
				prick(H, 0.5)
			else
				prick(H, 2)
				H.Paralyze(40)
				to_chat(H, "<span_class = 'userdanger'>Your feet are pierced by [P]'s spikes!</span>")
		else
			prick(C)

/datum/component/spikes/proc/setarmor(datum/source, datum/species/S) //this is a proc used to make sure a change in species won't fuck up the armor bonus.
	SIGNAL_HANDLER

	if(ishuman(parent))
		var/mob/living/carbon/human/H = parent
		finalarmor = armor
		if(H.dna.species.armor + armor > 35) //anything higher than this seems a bit much for a level 0 symptom
			finalarmor = max(0, (35 - H.dna.species.armor)) //don't make high armor species invinceable, but don't lower their armor if their armor is too high already
		H.dna.species.armor += finalarmor

/datum/component/spikes/proc/checkdiseasecure(datum/source, var/diseaseid)
	SIGNAL_HANDLER

	if(diseaseid == id)
		qdel(src) //we were cured! time to go.

/datum/component/spikes/proc/removearmor(datum/source, var/datum/component/C)
	SIGNAL_HANDLER

	if(C != src)
		return
	if(ishuman(parent) && armor)
		var/mob/living/carbon/human/H = parent
		H.dna.species.armor -= finalarmor
